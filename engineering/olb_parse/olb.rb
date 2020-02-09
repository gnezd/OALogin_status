#!/usr/bin/ruby

class Batch
	def initialize(olbpath)
	
fin = File.open(olbpath, "r")
raw = fin.readlines
(0..raw.size-1).each do |ln|
	if result = raw[ln].chomp.match(/^\[([\d\D]*)\]$/) #if tag
		puts result[1]
	end #if tag

end

	
	end
end


a = Batch.new(ARGV[0])
