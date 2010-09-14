require 'mkmf'

have_header('linux/inotify.h')
have_header("version.h")
have_type("OpenFile", ["ruby.h", "rubyio.h"])
create_makefile('inotify', 'ext')
