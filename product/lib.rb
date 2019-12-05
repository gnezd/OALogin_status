#!/usr/bin/ruby

require 'time'

def display_bytes(str)
	ret = String.new
	str.each_byte do  |byte|
	ret += "%02X|" % byte
	end
return ret
end

def readint(ols, ptr)
	return ols[ptr..ptr+3].unpack('l')[0]
end

def read_text_field(ols, ptr, field_name)

	field_ptr = readint(ols, ptr)
	ptr += 4
	raise "Not this field #{field_name} at #{ptr}!" unless ols[ptr..ptr+3+field_name.length] == [field_name.length].pack('l')+field_name 
	field_l = readint(ols, ptr+4+field_name.length)
	raise "Field length invalid: field_ptr is #{field_ptr} but field length goes to #{ptr+4+field_name.length+4+field_l}" unless field_ptr == ptr+4+field_name.length+4+field_l 
	ptr = ptr+4+field_name.length+4	
	field_value = ols[ptr..ptr+field_l-1]
	ptr = field_ptr

	return field_value, ptr
end

def read_int_field(ols, ptr, field_name)

	data, ptr = read_32b(ols, ptr, field_name)
	return data.unpack('l')[0], ptr
end

def read_32b(ols, ptr, field_name)

	field_ptr = readint(ols, ptr)
	#puts "field_ptr when reading #{field_name} at #{ptr} points to #{field_ptr}"
	ptr += 4
	raise "Not this field #{field_name} at #{ptr}!" unless ols[ptr..ptr+3+field_name.length] == [field_name.length].pack('l')+field_name 
	field_l = 4
	raise "Field length invalid: field_ptr is #{field_ptr} but field length goes to #{ptr+4+field_name.length+field_l}" unless field_ptr == ptr+4+field_name.length+field_l 
	ptr = ptr+4+field_name.length	
	field_value = ols[ptr..ptr+field_l-1]
	ptr = field_ptr

	return field_value, ptr
end

def read_uk_field(ols, ptr, field_name)

	field_ptr = readint(ols, ptr)
	ptr += 4
	raise "Not this field #{field_name} at #{ptr}!" unless ols[ptr..ptr+3+field_name.length] == [field_name.length].pack('l')+field_name 
	data = ols[ptr+4+field_name.length..field_ptr-1]
	ptr = field_ptr
	return data, ptr	
end

#----

def parse_plate(ols, ptr)

	begin

	cover_batches = readint(ols, ptr)
	ptr += 15
	batch_num = readint(ols, ptr)
	ptr +=4
	#batch_num, ptr = read_int_field(ols, ptr, "Batches") This length check is then impossible. have to let the next field do that.
	#puts "number of batches = #{batch_num}"
	
	batch = 1
	batches = Array.new
	while batch <= batch_num do
	#	puts "trying to get batch number #{batch}"
		owner, ptr = read_text_field(ols, ptr, "Owner")
		id, ptr = read_text_field(ols, ptr, "ID")
		logtimeraw, ptr = read_int_field(ols, ptr, "LogTime")
		locations, ptr = read_uk_field(ols, ptr, "Locations")
		priority, ptr = read_32b(ols, ptr, "Priority")
		raise "Expecting EOO at #{ptr}!" if ptr != readint(ols, ptr) || ols[ptr+4..ptr+10] != "\x03\0\0\0EOO"
		batches.push([owner, id, Time.strptime(logtimeraw.to_s, "%s"), locations, priority])
		ptr += 11
		batch += 1
	end
	raise "batch number don't agree #{batch_num} != #{batches.length}" unless batch_num == batches.length
	#puts "after batch list ptr = #{ptr}"

	desc, ptr = read_text_field(ols, ptr, "Desc")
	owner, ptr = read_text_field(ols, ptr, "Owner")
	plate, ptr = read_uk_field(ols, ptr, "Plate")
	excludes, ptr = read_32b(ols, ptr, "Excludes")
	holder, ptr = read_32b(ols, ptr, "Holder")
	usage, ptr = read_32b(ols, ptr, "Usage")
	lastusedpos, ptr = read_32b(ols, ptr, "LastUsedPos")
	
	
	raise "Expecting EOO at #{ptr}!" if ptr != readint(ols, ptr) || ols[ptr+4..ptr+10] != "\x03\0\0\0EOO"
	ptr += 11
	return batches, desc, owner, plate, excludes, holder, usage, ptr
	end #begin
end

def parse_ols(path)
	
	eoo = "\x03\0\0\0EOO"
	times = 0
	begin	
	fo = File.open(path, "rb")
	ols = fo.read
	fo.close #close the ols immediately
	rescue
		retry if (times += 1) < 2
	end
	begin
	ptr = 0
	cover_ASBedInfo = readint(ols, ptr)
	raise "cover_ASBedInfo didn't close an EOO" unless ols[cover_ASBedInfo-7..cover_ASBedInfo-1] == eoo
#	puts "cover_ASBedInfo = #{cover_ASBedInfo}"
	ptr += 25

	batches_1, desc_1, owner_1, plate_str_1, excludes_1, holder_1, usage_1, ptr = parse_plate(ols, ptr)
	batches_2, desc_2, owner_2, plate_str_2, excludes_2, holder_2, usage_2, ptr = parse_plate(ols, ptr)
	
	raise "cover_ASBedInfo = #{cover_ASBedInfo} but ptr after two plate = #{ptr}" unless cover_ASBedInfo == ptr

	current, ptr = read_text_field(ols, ptr, "CurrentBatch")
	batch_ext, ptr = read_text_field(ols, ptr, "BatchFileExt")
	inj_state, ptr = read_32b(ols, ptr, "InjState")
	server_status_cycle, ptr = read_32b(ols, ptr, "ServerStatusCycle")
	oastat, ptr = read_32b(ols, ptr, "OAState")
	last_err, ptr = read_text_field(ols, ptr, "LastError")
	auto_smplr, ptr = read_text_field(ols, ptr, "AutoSampler")
	analysis_time, ptr = read_32b(ols, ptr, "AnalysisTime")
	analysis_time = analysis_time.unpack('f')[0]
	invalid_plates, ptr = read_32b(ols, ptr, "InvalidPlates")
	health, ptr = read_text_field(ols, ptr, "InstrumentHealthy")

	raise "Expecting EOO at #{ptr}!" if ptr != readint(ols, ptr) || ols[ptr+4..ptr+10] != "\x03\0\0\0EOO"

	return [batches_1, desc_1, owner_1, plate_str_1, excludes_1, holder_1, usage_1], [batches_2, desc_2, owner_2, plate_str_2, excludes_2, holder_2, usage_2], current, batch_ext, inj_state, server_status_cycle, oastat, last_err, auto_smplr, analysis_time, invalid_plates, health

	end #begin
end #func parse_ols

