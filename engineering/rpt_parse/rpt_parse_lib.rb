class OALogin_Report
def initialize(fname)
	
	puts "opening file #{fname}" #debug
	fin = File.open(fname, mode: 'r:ISO-8859-1')
	raw = fin.readlines
	fin.close
	@max_pressure = 0
	@curve = Array.new
	ptr = 0
	(0..raw.size-1).each do |ln|
	if raw[ln] == "Description\tSystem Pressure\r\n"
		puts "found Pressure start!"
		ptr = ln+3
		@max_pressure = raw[ptr].split("MaxIntensity\t")[1].to_f
		break
	end

	ptr += 3 #points to pressure trace line 1
	#puts raw[ptr]	
	while raw[ptr] =~ /^\d\./
		
		(t, p_norm) = raw[ptr].split(' ')
		@curve.push([t, p_norm*@max_pressure])
		ptr +=1
	end

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
