#!usr/bin/ruby

require 'inotify'
require 'find'

i = Inotify::Inotify.new

t = Thread.new do
	i.each_event do |ev|
		p ev.name
		p ev.mask
	end
end

raise("Specify a directory") if !ARGV[0]

Find.find(ARGV[0]) do |e| 
	if ['.svn', 'CVS', 'RCS'].include? File.basename(e) or !File.directory? e
		Find.prune
	else
		begin
			puts "Adding #{e}"
			i.add_watch(e, Inotify::CREATE | Inotify::DELETE | Inotify::MOVE)
		rescue
			puts "Skipping #{e}: #{$!}"
		end
	end
end

t.join
