#experimental test of new parsing underlayer before touching rpt_parse_lib.rb
class Tag
	attr_accessor :content, :children
	attr_reader :name, :depth, :parent
def adopt(orphan)
	puts "Adopting. Children num from #{@children.size}"
	@children.push(orphan)
	puts @children.size
end

def initialize(tag_name, depth, parent)
	
	@content = Hash.new
	@children = Array.new
	@name = tag_name
	@depth = depth
	@parent = parent
	
	@parent.adopt(self) if @parent != nil
	

end
end #end class Tag


class OALogin_Report
def initialize(fname)
path = fname
rpt = File.open(path, mode: 'r:ISO-8859-1')
raw = rpt.readlines
rpt.close

depth = 0
root = Tag.new("root", 0, nil)
puts root.name
current_head = root
alltags = Array.new


#(0..20).each do |ln|
(0..raw.size-1).each do |ln| #small scale test

if result = raw[ln].match(/(^\[)([\d\D]*)(\]\r\n)/) #tag?
	new_tag = Tag.new(result.captures[1], depth, current_head)
	raise "not bracket after tag!" if (raw[ln+1] =~ /^{/) == nil
	depth +=1

	puts "#{" "*new_tag.depth}[#{new_tag.name}] depth: #{new_tag.depth}, child of #{current_head.name}"
	current_head = new_tag
end

if raw[ln] =~ /^}/
	begin
	current_head = current_head.parent
	rescue
		puts "move up failed at line #{ln}: #{raw[ln]}"
	end
	depth -= 1
	#puts "#{" "*depth}now back at level of [#{tag_name.last}], depth #{depth}"
end

end #end line iteration

puts "At the end, depth #{current_head.depth}. [#{current_head.name}] has #{current_head.children.size} children:"

current_head.children.each do |child|
	puts child.name
end

puts root.children
end

end

path = ARGV[0]
rpt1 = OALogin_Report.new(path)


