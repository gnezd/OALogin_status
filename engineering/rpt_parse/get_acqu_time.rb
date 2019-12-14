#!/usr/bin/ruby
require './rpt_parse_lib.rb'
d
path = "/home/pi/Desktop/mount_points/sq1_e/Masslynx Projects/OALogin_rpt"

flist = Dir.foreach(path) do |f|
	if f =~ /(\.rpt)$/
		#puts "got rpt #{f}"
		date, time = get_acqtime(path+"/"+f)
		puts "#{f} acquired last at: #{date} #{time}"

	end
end

#date, time = get_acqtime(ARGV[0])
#puts "#{date} #{time}"
