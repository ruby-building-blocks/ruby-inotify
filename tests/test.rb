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
		assert_equal(Fixnum, (wd = @inotify.add_watch("/tmp", Inotify::CREATE)).class)
		assert(@inotify.rm_watch(wd))
	end
	def test4
		@inotify.add_watch("/tmp", Inotify::CREATE)
		begin 
			File.open(File.join("/tmp", "ruby-inotify-test-4"), 'w')
			@inotify.each_event do |ev|
				assert_equal(ev.class, Inotify::Event)
				assert_equal(ev.inspect, "<Inotify::Event:0xDEADBEEF name=FIXME mask=FIXME>")
				assert_equal(ev.name, "ruby-inotify-test-4")
				assert_equal(ev.mask, Inotify::CREATE)
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
