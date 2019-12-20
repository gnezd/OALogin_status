#!/usr/bin/ruby
require './rpt_parse_lib.rb'
require 'open3'
#Engineering test for mass pressure curve extraction

#pressure, curve = parse_rpt(ARGV[0])
#puts pressure
	#puts curve[0]
path1 = "../../testdata/rpts/Bode - AlKa - 23 - on.rpt"
path2 = "../../testdata/rpts/Bode - JF-9-184-10min.rpt"
rpt1 = OALogin_Report.new(path1)
rpt2 = OALogin_Report.new(path2)

puts rpt1.curve.size
puts rpt2.curve.size
gnuplot_data = ""
gnuplot_commands = <<"End"
set terminal svg size 700 400
set output "plot.svg"
set datafile separator " "

set style line 1 \
    linecolor rgb '#000000' \
    linetype 1 linewidth 2 \
    pointtype 7 pointsize 1.5
set style line 2 \
    linecolor rgb '#ff0000' \
    linetype 1 linewidth 2 \
    pointtype 5 pointsize 1.5

set xrange [0:7]
set yrange[0:*]
set key outside

plot 'test.gnu' index 0 with lines linestyle 1 t "1", \
'' index 1 with lines linestyle 2 t "2"

End

rpt1.curve.each do |pt|
  gnuplot_data << pt[0].to_s + " " + pt[1].to_s + "\n"
end
gnuplot_data << "\n\n"

rpt2.curve.each do |pt|
  gnuplot_data << pt[0].to_s + " " + pt[1].to_s + "\n"
end
gnuplot_data << "e\n"

gnuplot_out = File.new("test.gnu", "w")
gnuplot_out.write(gnuplot_data)
gnuplot_out.close

image, s = Open3.capture2(
  "gnuplot", 
  :stdin_data=>gnuplot_commands, :binmode=>true)
