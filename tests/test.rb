require 'test/unit'
require 'inotify'

class Test1 < Test::Unit::TestCase
	def test1
		i = Inotify.new
		assert_equal(Inotify, i.class)
	end
end
