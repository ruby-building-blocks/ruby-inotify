# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "inotify/inotify_native"

Gem::Specification.new do |s|
  s.name        = "ruby-inotify"
  s.version     = Inotify::VERSION
  s.authors     = ["Aria Stewart", "Jon Raiford"]
  s.email       = ["aredridel@nbtsc.org", "jon@raiford.org"]
  s.homepage    = "http://dinhe.net/~aredridel/projects/ruby/ruby-inotify"
  s.summary     = %q{Interface to Linux's Inotify (Ruby FFI version)}
  s.description = %q{An interface to Linux's inotify, for watching updates to directories.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "ffi"
end
