
def sample_logbook(rpt_path, output, last_n_day)
	fo = File.open(output+".csv", "w")
	pressure_curve_o = File.open("#{output}_p.csv", "w")
#rptpath = Dir.open(ARGV[0])
#Dir.chdir(rptpath)
fo.puts "rpt.name, sample.name, sample.description,sample.acqu_time, sample.lc_method, sample.ms_method, sample.inject_volume, max_pressure"


criteria = Proc.new {|filename, rpt| filename =~ /\.rpt$/ &&
		     Time.now-File.mtime(rpt_path+filename) < 86400*last_n_day.to_i
}
filelist = `find "#{rpt_path}" -mtime -#{last_n_day.to_i+1} -name "*.rpt" -printf '%Ts %f\n'| sort -n|cut -d ' ' -f2-`.split("\n")

puts "#{filelist.size} reports in last 24 hours<br>"
filelist.each do |file|

	rpt = OALogin_Report.new(rpt_path+file)
	next unless criteria[file, rpt]
	rpt.samples.each do |sample|
		fo.puts [rpt.name, sample.name, sample.description,sample.acqu_time, sample.lc_method, sample.ms_method, sample.inject_volume, sample. max_pressure].join(",")
		x, y = [sample.name], [""]
		sample.pressure_curve.each do |pt|
			x.push(pt[0])
			y.push(pt[1]*sample.max_pressure)
		end
		pressure_curve_o.puts x.join(",")
		pressure_curve_o.puts y.join(",")
	end

end #file iteration
fo.close
pressure_curve_o.close
end

