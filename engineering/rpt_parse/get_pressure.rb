#!/usr/bin/ruby
require './rpt_parse_lib.rb'
#Engineering test for mass pressure curve extraction

#pressure, curve = parse_rpt(ARGV[0])
#puts pressure
	#puts curve[0]
path = "../../testdata/rpts/Bode - AlKa - 23 - on.rpt"
rpt = OALogin_Report.new(path)

puts "max pessure: #{rpt.max_pressure}"
puts rpt.curve.size
