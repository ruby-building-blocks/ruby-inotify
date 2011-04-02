require 'find'
require 'inotify'

module Inotify

  class InotifyThread
    def initialize
      @inotify = Inotify.new
      @watch_list = Hash.new
      @reg_events = Hash.new {Array.new}
      @die_on_move = true
    end
 
    def start_thread
      @thread = Thread.new do 
        self.start_loop
      end
    end

    def start_loop
      @inotify.each_event do |notify_event|
        @reg_events.keys.each do |reg_event|
          if (notify_event.mask & reg_event) > 0
            @reg_events[reg_event].each do |event_block|
              # There is no way to get the new path if the watched directory is moved, so stop watching it
              if @die_on_move and InotifyBitmask.new(notify_event.mask).test?(:in_move_self)
                self.remove_watch(@watch_list[notify_event.wd])
                break
              else
                event_block.call(notify_event, @watch_list[notify_event.wd])
              end
            end
          end
        end
      end
    end

    def end_thread
      @thread.kill
    end

    def add_watch(pathname, bitmask, recursive)
      bm = InotifyBitmask.new(bitmask)
      if @die_on_move
        bm.set_flag(:in_move_self)
      end
      full_path = File.expand_path(pathname)
      wd = @inotify.add_watch(full_path, bm.bitmask)
      return wd if wd < 0
      @watch_list[wd] = full_path
      if recursive and FileTest.directory?(full_path)
        Dir.foreach(full_path) do |filename|
          full_filename = File.join(full_path, filename)
          if FileTest.directory?(full_filename)
            if filename[0] != ?.
              wd = self.add_watch(full_filename, bm.bitmask, recursive)
            end
          end
        end
      end
      wd
    end

    def remove_watch(pathname)
      wd = @watch_list.key(pathname)
      if !wd.nil?
        @inotify.rm_watch(wd)
        @watch_list.delete(wd)
      end
    end

    def register_event(bitmask, &block)
      @reg_events[bitmask] = @reg_events[bitmask] << block
    end
  end

end
