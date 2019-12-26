require 'time'

$debug = 0
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


class Sample

	attr_reader :max_pressure, :pressure_curve, :acqu_time, :name, :description, :lc_method, :ms_method, :position, :analysis_time, :inject_volume, :mslist
	def initialize(sample_tag)
		@pressure_curve = Array.new
		sample_tag.children.each do |depth1| #sample's children depth1, seeking [FUNCTION]
			if depth1.name == "FUNCTION"
				depth1.children.each do |depth2| #spectrum or chromatogram?
				if depth2.content["Description"] == "System Pressure"
					@max_pressure = depth1.content["MaxIntensity"]
					@pressure_curve = depth1.children[0].content.to_a
				end #end FUNCTION chromatogram
				end #end each depth2
			elsif depth1.name == "COMPOUND"#other chrom
				#Masslist
				@mslist = depth1.content.keys[1..]
			elsif depth1.name == "INLET PARAMETERS"#other chrom
				puts "In here" 
					
			end #if FUNCTION
		end #end sample's children depth1
		@acqu_time = Time.parse(sample_tag.content["Date"]+" "+sample_tag.content["Time"])
		@name = sample_tag.content["SampleID"].to_s
		@description = sample_tag.content["SampleDescription"].to_s
		@lc_method = sample_tag.content["InletMethod"].to_s
		@ms_method = sample_tag.content["MSMethod"].to_s
		@position = sample_tag.content["Well"].to_s
		@analysis_time = sample_tag.content["AnalysisTime"].to_f
		@inject_volume = sample_tag.content["InjectionVolume"].to_f
	end #end init
end #end class


class OALogin_Report
	attr_reader :name, :samples, :root
	#readonly so rar	
	def initialize(fname)
		rpt = File.open(fname, mode: 'r:ISO-8859-1')
		raw = rpt.readlines
		rpt.close

		@name = fname.split('/').last
		@samples = []
		@root = Tag.new("root", 0, nil)
		depth = 0
		current_head = @root
(0..raw.size-1).each do |ln| #line iteration

if result = raw[ln].match(/(^\[)([\d\D]*)(\])(\r)?(\n)/) #tag?
	new_tag = Tag.new(result.captures[1], depth, current_head) #newtag
	puts "New tag id = #{new_tag.object_id}" if $debug == 1
	raise "not bracket after tag!" if (raw[ln+1] =~ /^{/) == nil
	depth +=1

	puts "#{" "*new_tag.depth}[#{new_tag.name}] depth: #{new_tag.depth}, child of #{current_head.name}" if $debug == 1
	current_head = new_tag

		

end #end if new tag creation

if raw[ln] =~ /^}/
	begin
	puts "end tag, object id = #{current_head.object_id}" if $debug == 1
	current_head = current_head.parent
	rescue
		puts "move up failed at line #{ln}: #{raw[ln]}"
	end
	depth -= 1
	puts "#{" "*depth}now back at level of [#{current_head.name}], depth #{depth}" if $debug == 1
end

	if match=raw[ln].match(/([^\t]*)\t([^\t\r\n]*)(\r)?(\n)/)
		#puts "#{ln}:#{raw[ln]}"
		current_head.content[match[1]]=match[2]
	end

end #end line iteration

puts "At the end of rpt reading, depth #{current_head.depth}. [#{current_head.name}] has #{current_head.children.size} children:" if $debug == 1

#begin Sample object creation

	root.children.each do |sample_tag|
		@samples.push(Sample.new(sample_tag))
	end #end each children
	end

end


def get_acqtime (fname)
		
	#puts "opening file #{fname}" #debug
	fin = File.open(fname, mode: 'r:ISO-8859-1')
	raw = fin.readlines
	fin.close
	date, time = 0

	ptr = 0
	while ptr < raw.size-1
		
		if raw[ptr] =~ /Acquired\sDate/
	#		puts "#{ptr+1}:#{raw[ptr]}"
			date = raw[ptr].split('        ')[1].chomp
		end
		if raw[ptr] =~ /Acquired\sTime/
	#		puts "#{ptr+1}:#{raw[ptr]}"
			time = raw[ptr].split('        ')[1].chomp
		end
		ptr +=1
	end

	return date, time
	
end
$debug = 0
rpt = OALogin_Report.new(ARGV[0])
puts rpt.samples[0].acqu_time
puts rpt.samples[0].name
puts rpt.samples[0].description
puts rpt.samples[0].lc_method
puts rpt.samples[0].ms_method
puts rpt.samples[0].position
puts rpt.samples[0].analysis_time
puts rpt.samples[0].inject_volume
puts rpt.samples[0].mslist.size


