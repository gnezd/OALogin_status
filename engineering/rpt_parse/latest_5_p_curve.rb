#experimental test of new parsing underlayer before touching rpt_parse_lib.rb
require 'open3'
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

if result = raw[ln].match(/(^\[)([\d\D]*)(\]\r\n)/) #tag?
	new_tag = Tag.new(result.captures[1], depth, current_head)
	raise "not bracket after tag!" if (raw[ln+1] =~ /^{/) == nil
	depth +=1

	#puts "#{" "*new_tag.depth}[#{new_tag.name}] depth: #{new_tag.depth}, child of #{current_head.name}"
	current_head = new_tag
#then the tag type dependent things

	#if raw[ln].match(/([^\t]*)\t([^\t\r\n]*)(\r)?(\n)/)
		

end #end if new tag creation

if raw[ln] =~ /^}/
	begin
	current_head = current_head.parent
	rescue
		puts "move up failed at line #{ln}: #{raw[ln]}"
	end
	depth -= 1
	#puts "#{" "*depth}now back at level of [#{tag_name.last}], depth #{depth}"
end

	if match=raw[ln].match(/([^\t]*)\t([^\t\r\n]*)(\r)?(\n)/)
		#puts "#{ln}:#{raw[ln]}"
		current_head.content[match[1]]=match[2]
	end

end #end line iteration

#puts "At the end of rpt reading, depth #{current_head.depth}. [#{current_head.name}] has #{current_head.children.size} children:"


end

end

#main: test to output the five last submission pressure curves
path = ARGV[0]
rpt_list = `ls -1ct \"#{path}\"/*.rpt|head -5`.split("\n")
fname_list = []
plot_data = File.new("data", "w")

rpt_list.each do |fname|

rpt = OALogin_Report.new(fname)

puts rpt.root.children[0].content["FileName"]

rpt.root.children.each do |sample|
fname_list.push(sample.content["FileName"])
sample.children.each do |child| #children of 1st sample
	if child.name == "FUNCTION"
		child.children.each do |spcr| #spectrum or chromatogram?
			if spcr.content["Description"] == "System Pressure"
			
			spcr.children[0].content.each_key do |key|
				plot_data.puts "#{key}\t#{spcr.children[0].content[key].to_f*spcr.content["MaxIntensity"].to_f/100}"
			end
			plot_data.write("\n\n")
			end
		end#end iteration spcr
	end

end # end children of 1st sample
end #end sample

end #end report iter

plot_data.close


gnuplot_command =<<"END"

set terminal svg size 1000 600
set output "plot.svg"

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
END
#plot 'data' index 0 with lines linestyle 1 t "1", \
#'' index 1 with lines linestyle 2 t "2"


gnuplot_command  << "plot 'data' index 0 with lines t \"#{fname_list[0]}\""
(1..fname_list.size-1).each do |fname_index|
	gnuplot_command << ", '' index #{fname_index} with lines t \"#{fname_list[fname_index]}\""
end
puts "gnuplot_command:"
puts gnuplot_command


image, s = Open3.capture2(
"gnuplot",
:stdin_data=> gnuplot_command, :binmode=>true)
