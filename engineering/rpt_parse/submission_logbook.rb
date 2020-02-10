require './rpt_parse_lib.rb'
fo = File.open("last_24hr.csv", "w")
#rptpath = Dir.open(ARGV[0])
#Dir.chdir(rptpath)
rptlist = []

fo.puts "rpt.name, sample.name, sample.description,sample.acqu_time, sample.lc_method, sample.ms_method, sample.inject_volume"


criteria = Proc.new {|filename, rpt| filename =~ /\.rpt$/ &&
		     Time.now-File.mtime(filename) < 86400
#		     rpt.samples[0].name =~ /QC/
}
filelist = `find "#{ARGV[0]}" -mtime -1 -name "*.rpt"`.split("\n")
puts filelist.size
filelist.each do |file|

	rpt = OALogin_Report.new(file)
	next unless criteria[file, rpt]
	rpt.samples.each do |sample|
	fo.puts [rpt.name, sample.name, sample.description,sample.acqu_time, sample.lc_method, sample.ms_method, sample.inject_volume].join(",")
	end

end #file iteration
fo.close
