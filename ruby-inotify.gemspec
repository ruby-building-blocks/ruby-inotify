require 'rake'
GemFiles = FileList['examples/*', 'ext/*', 'tests/*', 'lib/*', 'Rakefile', 'MANIFEST']
GemFiles.exclude('ext/*.o')
GemFiles.exclude('**/Makefile')
GemFiles.exclude('**/semantic.cache')
GemFiles.exclude('ext/*.so')

spec = Gem::Specification.new do |s|
  s.platform            =  Gem::Platform::CURRENT
  s.name                =  "ruby-inotify"
  s.description		= "An interface to Linux's inotify, for watching updates to directories."
  s.version             =  "0.1.0"
  s.homepage = "http://dinhe.net/~aredridel/projects/ruby/ruby-inotify"
  s.author              =  "Aria Stewart"
  s.email               =  "aredridel@nbtsc.org"
  s.summary             =  "Interface to Linux's Inotify (C version)"
  s.files               =  GemFiles.to_a
  s.extensions         <<  'ext/extconf.rb'
  s.require_path        =  'lib'
  s.test_files		=  Dir.glob('tests/test_*.rb')
  s.extra_rdoc_files	=  ["MANIFEST"]
end
