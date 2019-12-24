#experimental test of new parsing underlayer before touching rpt_parse_lib.rb
class Tag
	attr_accessor :content, :children
	attr_reader :name, :depth, :parent
def adopt(orphan)
	#print "Adopting. Children num from #{@children.size}"
	@children.push(orphan)
#	print ". After adoption children num became #{@children.size}"
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
	attr_reader	:root
def initialize(fname)
path = fname
rpt = File.open(path, mode: 'r:ISO-8859-1')
raw = rpt.readlines
rpt.close

depth = 0
@root = Tag.new("root", 0, nil)
current_head = @root


#(0..20).each do |ln|
(0..raw.size-1).each do |ln|

if result = raw[ln].match(/(^\[)([\d\D]*)(\])(\r)?(\n)/) #tag?
	new_tag = Tag.new(result.captures[1], depth, current_head)
	raise "not bracket after tag!" if (raw[ln+1] =~ /^{/) == nil
	depth +=1

	puts "#{" "*new_tag.depth}[#{new_tag.name}] depth: #{new_tag.depth}, child of #{current_head.name}"
	current_head = new_tag

		

end #end if new tag creation

if raw[ln] =~ /^}/
	begin
	current_head = current_head.parent
	rescue
		puts "move up failed at line #{ln}: #{raw[ln]}"
	end
	depth -= 1
	puts "#{" "*depth}now back at level of [#{current_head.name}], depth #{depth}"
end

	if match=raw[ln].match(/([^\t]*)\t([^\t\r\n]*)(\r)?(\n)/)
		#puts "#{ln}:#{raw[ln]}"
		current_head.content[match[1]]=match[2]
	end

end #end line iteration

puts "At the end of rpt reading, depth #{current_head.depth}. [#{current_head.name}] has #{current_head.children.size} children:"


end

end

path = ARGV[0]
rpt = OALogin_Report.new(path)

