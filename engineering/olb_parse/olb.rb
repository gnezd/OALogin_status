#!/usr/bin/ruby

class Batch
	attr_reader :batch_param, :plates, :samples
	def initialize(olbpath)
	
@batch_param = {}
@plates, @samples = [], []
ptr = []
fin = File.open(olbpath, "r")
raw = fin.readlines
current_plate=0

(0..raw.size-1).each do |ln|
	if result = raw[ln].chomp.match(/^\[([\w]*):?(\d)?:?(\d)?\]$/) #if tag
#	puts "matching tag #{result[0]}"
		case result[1]
		when "Batch"
			ptr = @batch_param
		#	puts "batch tag"
		when "Sample"
			@samples.push(Hash.new)
			ptr = @samples.last
			ptr["plate"], ptr["vial"] = result[2..3]
			raise "plate # dosn't match with file#{olbpath} at line #{ln}, revise logic!" if ptr["plate"] != current_plate
		when "Plate"
			@plates.push(Hash.new)
			ptr = @plates.last
			ptr["index"] = current_plate = result[2]
		end #end tag type
	elsif result = raw[ln].chomp.match(/([^=]+)=([\w\W]*)/)
		#puts "#{result[1]} === #{result[2]}"
		ptr["#{result[1]}"] = result[2]
	else
		raise "Unrecognizable line: #{raw[ln]}"
	end #if tag/line

end

	
	end
end


a = Batch.new(ARGV[0])
a.batch_param.each {|pair| puts pair.join "\t"}

