require 'mkmf'

have_header('linux/inotify.h')
create_makefile('inotify', 'ext')
