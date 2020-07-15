#!/usr/bin/ruby

def sample_logbook(rpt_path, output)
	fo = File.open(output+".csv", "w")
	fo.puts "Generated ad #{Time.now}"
	fo.puts "rpt.name, sample.name, sample.description, sample.position, sample.acqu_time, sample.lc_method, sample.ms_method, sample.ms_tune, sample.inject_volume, max_pressure"
=begin
criteria = Proc.new {|filename, rpt| filename =~ /\.rpt$/ &&
		     Time.now-File.mtime(rpt_path+filename) < 86400*last_n_day.to_i
}
=end
#filelist = `find "#{rpt_path}" -mtime -#{last_n_day.to_i+1} -name "*.rpt" -printf '%Ts %f\n'| sort -n|cut -d ' ' -f2-`.split("\n")
filelist = `find "#{rpt_path}" -name "*.rpt" -mtime -1 -daystart -printf '%Ts %f\n'| sort -n|cut -d ' ' -f2-`.split("\n")

puts "#{filelist.size} reports to generate from #{rpt_path}"
filelist.each do |file|

	rpt = OALogin_Report.new(rpt_path+file)
	#next unless criteria[file, rpt]
	rpt.samples.each do |sample|
		puts rpt.name
		fo.puts ["\"#{rpt.name}\"", "\"#{sample.name}\"", "\"#{sample.description}\"", "\"#{sample.position}\"", sample.acqu_time, sample.lc_method, sample.ms_method, sample.ms_tune, sample.inject_volume, sample. max_pressure].join(",")
#		x, y = [sample.name], [""]
#		sample.pressure_curve.each do |pt|
#			x.push(pt[0])
#			y.push(pt[1]*sample.max_pressure)
#		end
#		pressure_curve_o.puts x.join(",")
#		pressure_curve_o.puts y.join(",")
	end

end #file iteration
fo.close
#pressure_curve_o.close
end

Dir.chdir('/home/ydzeng/OALogin_status/product/')
require '/home/ydzeng/OALogin_status/product/settings.rb'
require '/home/ydzeng/OALogin_status/product/lib.rb'
sample_logbook($machines[0].rpt_path, "/var/www/html/logbook/#{$machines[0].name}-#{Time.now.strftime("%Y-%m%d")}")
sample_logbook($machines[1].rpt_path, "/var/www/html/logbook/#{$machines[1].name}-#{Time.now.strftime("%Y-%m%d")}")

