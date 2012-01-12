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
	def test3
		wd = @inotify.add_watch("/tmp", Inotify::CREATE)
		assert_equal(Fixnum, wd.class)
		assert(@inotify.rm_watch(wd))
	end
	def test4
		@inotify.add_watch("/tmp", Inotify::CREATE)
		begin 
			File.open(File.join("/tmp", "ruby-inotify-test-4"), 'w')
			@inotify.each_event do |ev|
				assert_equal(Inotify::Event, ev.class)
				assert_equal('<Inotify::Event name="ruby-inotify-test-4" mask=256 wd=1>', ev.inspect)
				assert_equal("ruby-inotify-test-4", ev.name)
				assert_equal(Inotify::CREATE, ev.mask)
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
