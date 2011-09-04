require 'ffi'

module Inotify

    MAX_NAME_SIZE = 4096
    ACCESS = 0x00000001
    MODIFY = 0x00000002
    ATTRIB = 0x00000004
    CLOSE_WRITE = 0x00000008
    CLOSE_NOWRITE = 0x00000010
    OPEN = 0x00000020
    MOVED_FROM = 0x00000040
    MOVED_TO = 0x00000080
    CREATE = 0x00000100
    DELETE = 0x00000200
    DELETE_SELF = 0x00000400
    MOVE_SELF = 0x00000800
    # Events sent by the kernel.
    UNMOUNT = 0x00002000
    Q_OVERFLOW = 0x00004000
    IGNORED = 0x00008000
    ONLYDIR = 0x01000000
    DONT_FOLLOW = 0x02000000
    MASK_ADD = 0x20000000
    ISDIR = 0x40000000
    ONESHOT = 0x80000000

    class EventStruct < FFI::Struct
      layout(
        :wd, :int,
        :mask, :uint32,
        :cookie, :uint32,
        :len, :uint32)
    end

    class Event
      def initialize(struct, buf)
        @struct, @buf = struct, buf
      end

      define_method(:wd) { @struct[:wd] }
      define_method(:mask) { @struct[:mask] }
      define_method(:cookie) { @struct[:cookie] }
      define_method(:len) { @struct[:len] }
      def name
        @struct[:len] > 0 ? @buf.get_string(16, @struct[:len]) : ''
      end

      def inspect
        "<%s name=%s mask=%s wd=%s>" % [
          self.class,
          self.name,
          self.mask,
          self.wd
        ]
      end
    end

    class Inotify
      extend FFI::Library
      ffi_lib FFI::Platform::LIBC
      attach_function :inotify_init, [], :int
      attach_function :inotify_add_watch, [:int, :string, :uint32], :int
      attach_function :inotify_rm_watch, [:int, :uint32], :int
      attach_function :read, [:int, :pointer, :size_t], :ssize_t
      attach_function :inotify_close, :close, [:int], :int
      def initialize
        @fd = self.inotify_init
        @io = FFI::IO.for_fd(@fd)
      end
      def add_watch(string, uint32)
        self.inotify_add_watch(@fd, string, uint32)
      end
      def rm_watch(uint32)
        self.inotify_rm_watch(@fd, uint32)
      end
      def close
        self.inotify_close(@fd)
      end
      def each_event
        loop do
          ready = IO.select([@io], nil, nil, nil)
          yield self.read_event
        end
      end
      def read_event
        buf = FFI::Buffer.alloc_out(EventStruct.size + MAX_NAME_SIZE, 1, false)
        ev = EventStruct.new(buf)
        n = self.read(@fd, buf, buf.total)
        Event.new(ev, buf)
      end
    end
end