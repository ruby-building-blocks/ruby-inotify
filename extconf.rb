require 'mkmf'

have_func('inotify_init', 'linux/inotify.h')
create_makefile('inotify', 'ext')
