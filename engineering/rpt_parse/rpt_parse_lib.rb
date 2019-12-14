class OALogin_Report
def initialize(fname)
	
	puts "opening file #{fname}" #debug
	fin = File.open(fname, mode: 'r:ISO-8859-1')
	raw = fin.readlines
	fin.close
	@max_pressure = 0
	@curve = Array.new
	ptr = 0
	
	while raw[ptr] != "Description\tSystem Pressure\r\n"
		ptr += 1
		raise "Cannot find pressure trace!" if ptr > raw.size
	end
	
	if raw[ptr] == "Description\tSystem Pressure\r\n"
		puts "found Pressure start!"
		ptr +=3
		@max_pressure = raw[ptr].split("MaxIntensity\t")[1].to_f
	end
	ptr +=3
	#debug_counter = 0
	while raw[ptr] =~ /^\d\./
		#break if debug_counter > 10
		(t, p_norm) = raw[ptr].split(' ')
		@curve.push([t, p_norm.to_f*@max_pressure/100])
		ptr +=1
		#debug_counter+=1
	end

	return self
end
	def max_pressure 
		return @max_pressure
	end
	def curve 
		return @curve
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
