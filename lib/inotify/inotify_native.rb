require 'rubygems'
require 'ffi'

  # The Inotify class is a simple wrapper around the inotify functionality provided by the OS
  class Inotify

    VERSION = "1.0.2" # :nodoc:

    extend FFI::Library
    ffi_lib FFI::Platform::LIBC

    # The maximum supported size of the name argument in the inotify event structure
    MAX_NAME_SIZE = 4096 # :nodoc:

    # File was accessed (read) (*)
    ACCESS        = 0x00000001
    # File was modified (*)
    MODIFY        = 0x00000002
    # Metadata changed, e.g., permissions, timestamps,
    # extended attributes, link count (since Linux 2.6.25),
    # UID, GID, etc. (*)
    ATTRIB        = 0x00000004  
    # File opened for writing was closed (*)                            
    CLOSE_WRITE   = 0x00000008  
    # File not opened for writing was closed (*)  
    CLOSE_NOWRITE = 0x00000010
    # File was opened (*)  
    OPEN          = 0x00000020
    # File moved out of watched directory (*)  
    MOVED_FROM    = 0x00000040
    # File moved into watched directory (*)  
    MOVED_TO      = 0x00000080
    # File/directory created in watched directory (*)  
    CREATE        = 0x00000100
    # File/directory deleted from watched directory (*)  
    DELETE        = 0x00000200
    # Watched file/directory was itself deleted  
    DELETE_SELF   = 0x00000400
    # Watched file/directory was itself moved  
    MOVE_SELF     = 0x00000800
    # File system containing watched object was unmounted
    UNMOUNT       = 0x00002000
    # Event queue overflowed (wd is -1 for this event)
    Q_OVERFLOW    = 0x00004000
    # Watch was removed explicitly (inotify_rm_watch(2)) or
    # automatically (file was deleted, or file system was
    # unmounted)
    IGNORED       = 0x00008000
    # (since Linux 2.6.15) Only watch pathname if it is a directory
    ONLYDIR       = 0x01000000
    # (since Linux 2.6.15) Don't dereference pathname if it is a symbolic link
    DONT_FOLLOW   = 0x02000000
    # (since Linux 2.6.36) 
    # By default, when watching events on the children of a
    # directory, events are generated for children even after
    # they have been unlinked from the directory.  This can
    # result in large numbers of uninteresting events for some
    # applications (e.g., if watching /tmp, in which many
    # applications create temporary files whose names are
    # immediately unlinked).  Specifying IN_EXCL_UNLINK
    # changes the default behavior, so that events are not
    # generated for children after they have been unlinked
    # from the watched directory.
    EXCL_UNLINK   = 0x04000000  
    # Add (OR) events to watch mask for this pathname if it
    # already exists (instead of replacing mask)
    MASK_ADD      = 0x20000000 
    # Subject of this event is a directory
    ISDIR         = 0x40000000
    # Monitor pathname for one event, then remove from watch list
    ONESHOT       = 0x80000000
    # Both of the close events
    CLOSE      = (CLOSE_WRITE | CLOSE_NOWRITE)  
    # Both of the move events
    MOVE       = (MOVED_FROM | MOVED_TO)        
    #All of the events
    ALL_EVENTS = (ACCESS | MODIFY | ATTRIB | CLOSE_WRITE | \
       CLOSE_NOWRITE | OPEN | MOVED_FROM | \
       MOVED_TO | CREATE | DELETE | DELETE_SELF | MOVE_SELF)

    attach_function :inotify_init, [], :int
    attach_function :inotify_add_watch, [:int, :string, :uint32], :int
    attach_function :inotify_rm_watch, [:int, :uint32], :int
    attach_function :read, [:int, :pointer, :size_t], :ssize_t
    attach_function :inotify_close, :close, [:int], :int

    # When creating a new instance of this class, an inotify instance is created in the OS.
    def initialize # :nodoc:
      @fd = self.inotify_init
      @io = FFI::IO.for_fd(@fd)
    end

    # add_watch() adds a new watch, or modifies an existing watch, for the
    # file whose location is specified in pathname; the caller must have read
    # permission for this file. The events to be
    # monitored for pathname are specified in the mask bit-mask argument.
    # On success, inotify_add_watch() returns a nonnegative watch descriptor (wd), or
    # -1 if an error occurred.
    def add_watch(pathname, mask)
      self.inotify_add_watch(@fd, pathname, mask)
    end

    # rm_watch() removes the watch associated with the watch descriptor wd.
    # On success, returns zero, or -1 if an error occurred.
    def rm_watch(wd)
      self.inotify_rm_watch(@fd, wd)
    end

    # close() stops the processing of events and closes the
    # inotify instance in the OS
    def close
      self.inotify_close(@fd)
    end

    # each_event() provides an easy way to loop over all events as they occur
    def each_event
      loop do
        ready = IO.select([@io], nil, nil, nil)
        event = self.read_event
        yield event
      end
    end

    # read_event() attempts to read the next inotify event from the OS
    def read_event # :nodoc:
      buf = FFI::Buffer.alloc_out(EventStruct.size + MAX_NAME_SIZE, 1, false)
      ev = EventStruct.new(buf)
      n = self.read(@fd, buf, buf.total)
      Event.new(ev, buf)
    end

    # Internal class needed for FFI support
    class EventStruct < FFI::Struct # :nodoc:
      layout(
        :wd, :int,
        :mask, :uint32,
        :cookie, :uint32,
        :len, :uint32)
    end

    # The Inotify::Event class is used by Inotify when calling Inotify each_event method
    class Event

      def initialize(struct, buf) # :nodoc:
        @struct, @buf = struct, buf
      end

      # Returns the watch descriptor (wd) associated with the event
      def wd
        @struct[:wd]
      end

      # Returns the mask describing the event
      def mask
        @struct[:mask]
      end

      # Returns the cookie associated with the event.  If multiple events are triggered from the
      # same action (such as renaming a file or directory), this value will be the same.
      def cookie
        @struct[:cookie]
      end

      def len # :nodoc:
        @struct[:len]
      end

      # Returns the file name associated with the event, if applicable
      def name
        @struct[:len] > 0 ? @buf.get_string(16, @struct[:len]) : ''
      end

      def inspect # :nodoc:
        "<%s name=%s mask=%s wd=%s>" % [
          self.class,
          self.name,
          self.mask,
          self.wd
        ]
      end
    end

end
