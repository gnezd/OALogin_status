#experimental test of new parsing underlayer before touching rpt_parse_lib.rb
class Tag
	attr_accessor :content, :children
	attr_reader :name, :depth, :parent
def initialize(tag_name, depth, parent)
	
	@content = Hash.new
	@children = Array.new
	@name = tag_name
	@depth = depth
	@parent = parent

	parent.children.push(self)
	

end
end #end class Tag


class OALogin_Report
def initialize(fname)
path = fname
rpt = File.open(path, mode: 'r:ISO-8859-1')
raw = rpt.readlines
rpt.close

depth = 0
tag_names = ["root"]

#(0..20).each do |ln|
(0..raw.size-1).each do |ln| #small scale test

if result = raw[ln].match(/(^\[)([\d\D]*)(\]\r\n)/) #tag?
	tag_names.push(result.captures[1])
	raise "not bracket after tag!" if (raw[ln+1] =~ /^{/) == nil
	depth +=1	
	puts "#{" "*depth}[#{tag_names.last}] depth: #{depth}"
end

if raw[ln] =~ /^}/
	#puts "#{" "*depth}exiting one level"
	tag_names.pop
	depth -= 1
	#puts "#{" "*depth}now back at level of [#{tag_name.last}], depth #{depth}"
end

end #end line iteration

puts "At the end, #{tag_names}, depth #{depth}"

end

end

path = ARGV[0]
rpt1 = OALogin_Report.new(path)
