require './rpt_parse_lib.rb'
rptpath = Dir.open(ARGV[0])
Dir.chdir(rptpath)
rptlist = []

fo = File.open("last_24hr.csv")
output = "rpt.name, sample.name, sample.description,sample.acqu_time, sample.lc_method, sample.ms_method, sample.inject_volume"


criteria = Proc.new {|filename| filename =~ /\.rpt$/ ||
		     Time.now-File.mtime(filename) < 86400
}
Dir.glob("*.rpt").each do |file|

	next unless criteria[file]
	rpt = OALogin_Report.new(file)

	puts rpt.samples.size
	rpt.samples.each do |sample|
	output += [rpt.name, sample.name, sample.description,sample.acqu_time, sample.lc_method, sample.ms_method, sample.inject_volume].join(",")
	output += "\n"
end

end #file iteration
fo.puts output
fo.close
