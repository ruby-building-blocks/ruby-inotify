require 'test/unit'
require 'inotify'

class Test1 < Test::Unit::TestCase
	def setup
		@inotify = Inotify.new
	end
	def test1
		assert_equal(Inotify, @inotify.class)
	end
	def test2
		assert(@inotify.add_watch("/tmp", Inotify::CREATE))
	end
	def test_successful_watch
		wd = @inotify.add_watch("/tmp", Inotify::CREATE)
		assert_kind_of(Integer, wd)
		assert_equal(1, wd)
		assert_equal(0, @inotify.rm_watch(wd))
	end

	def test_unsuccessful_watch
		test_path = "/tmp/ruby-inotify-unsuccessful_watch"
		assert(!File.exists?(test_path))
		assert_equal(-1, @inotify.add_watch(test_path, Inotify::CREATE))
	end

        def test_remove_watch_by_pathname
		@inotify.add_watch("/tmp", Inotify::CREATE)
		assert_equal(0, @inotify.rm_watch('/tmp'))
        end

	def test_remove_nonexistant_watch
		assert_equal(-1, @inotify.rm_watch('/tmp'))
	end

	def test4
		@inotify.add_watch("/tmp", Inotify::CREATE)
		begin 
			File.open(File.join("/tmp", "ruby-inotify-test-4"), 'w');
			@inotify.each_event do |ev|
				assert_equal(Inotify::Event, ev.class)
				assert_equal('<Inotify::Event name="ruby-inotify-test-4" mask=256 wd=1 pathname="/tmp">', ev.inspect);
				assert_equal("ruby-inotify-test-4", ev.name)
				assert_equal(Inotify::CREATE, ev.mask)
				assert_equal('/tmp', ev.pathname)
				break
			end
		ensure
			File.unlink(File.join("/tmp", "ruby-inotify-test-4"))
		end
	end
	def teardown
		@inotify.close
	end
end
