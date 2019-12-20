#!/usr/bin/ruby
require './rpt_parse_lib.rb'
require 'nyaplot'

path1 = "../../testdata/rpts/Bode - AlKa - 23 - on.rpt"
path2 = "../../testdata/rpts/Bode - JF-9-184-10min.rpt"
rpt1 = OALogin_Report.new(path1)
rpt2 = OALogin_Report.new(path2)

plot = Nyaplot::Plot.new
plot.configure do
	width(1000)
	height(300)
end
plot.yrange([0,1000])
x=[];y=[]
rpt1.curve.each do |pt|
	x.push(pt[0])
	y.push(pt[1])
end
sc = plot.add(:scatter, x, y)
puts sc
plot.export_html("nyaplot_test.html")
