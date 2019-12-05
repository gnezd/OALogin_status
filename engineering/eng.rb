require './lib.rb'

def get_machine(sqnum)

	output = String.new
	path = "/home/ydzeng/mount_points/sq#{sqnum}_c/MassLynx/OALogin/Batchdb/"
	ols_path = "#{path}Status.ols"
#	if sqnum == 3; ols_path = "./1847.ols" end
	ols_updtime = File.mtime(ols_path)
	plate_1, plate_2, current, batch_ext, inj_state, server_status_cycle, oastat, last_err, auto_smplr, analysis_time, invalid_plates, health = parse_ols(ols_path)
	(0..plate_2[0].length-1).each do |i| #add spice to position
		plate_2[0][i][3][0..3] = "\x02\0\0\0"
	end
	batchlist = plate_1[0] + plate_2[0]
	batchlist.sort {|a, b| a[2] <=> b[2]}

	deg=0
	(0..batchlist.length-1).each do |i| #catch degeneracy when cross plate
		if batchlist[i][1] == batchlist[i-1][1] && i > 1
			deg += 1
		end
	end


	output += "<div class=\"machinebox\"><table class=\"machinetable\" id =\"sq#{sqnum}\">\n<p class=\"m_table_title\">SQD#{sqnum} Queue:</p>\n"

	if health == "FALSE"
		output += "<p>Machine not running properly.</p>\n"
	elsif batchlist.length == 0
		output += "<p>Machine has an empty Queue.</p>\n"
	else
		#report the queue
		output += "<p> #{batchlist.length-deg} job"
		output += "s" if batchlist.length-deg > 1
		mins = (analysis_time/60).to_int 
		output += " in the queue, expects to finish in "
		output += "#{mins} mins and " if mins > 0
		output += "#{(analysis_time.to_int%60)} seconds.</p>
		<tr class=\"first_row\">
		<td nowrap class =\"first_row\">Job name</td>
		<td nowrap class =\"first_row\">Submitted time</td>
		<td nowrap class =\"first_row\">Locations</td>
		<td nowrap class =\"first_row\">Method</td>
		<td nowrap class =\"first_row\">Time(min)</td>
		<td nowrap class =\"first_row\">Priority</td></tr>"
#batchlist loop
		batchlist.each do |batch|
			output += "<tr #{'id ="current"' if batch[1] == current}><td nowrap>#{batch[1]}</td>
			<td nowrap class=\"internal\">#{batch[2]}</td>"
			if batch[3].length == 12 #if in the plate
			positions = "Plate #{batch[3][0..3].unpack('l')[0].to_s} ##{batch[3][4..7].unpack('l')[0].to_s}"
			if batch[3][4..7] != batch[3][8..11] #more than one?
				positions += "~#{batch[3][8..11].unpack('l')[0].to_s}"
			end
			end
			output += "<td nowrap class=\"internal\">#{positions}</td>"
			lcmethod = `grep 'LCMethod=' "#{path}/#{batch[1]}.OLB"`
			lcmethod = lcmethod.split('=')[1].chomp
			output += "<td nowrap class=\"internal\">#{lcmethod}</td>"
			time_min = `grep 'AnalysisTime=' "#{path}/#{batch[1]}.OLB"`
			time_min = time_min.split('=')[1].chomp
			output += "<td nowrap class=\"internal\">#{time_min}</td>"
			
			output += "<td nowrap class=\"internal\">#{batch[4].unpack('l')[0]}</td></tr>"
		end

#end batchlist loop


	end

	output += "</table><p>Machine status updated at #{ols_updtime}</p>\n</div>"
	
	return output

end


	path = "/home/pi/Desktop/mount_points/sq3_c/MassLynx/OALogin/Batchdb/"
	ols_path = "#{path}Status.ols"
	#ols_path = "./crossplate.ols"
	plate_1, plate_2, current, batch_ext, inj_state, server_status_cycle, oastat, last_err, auto_smplr, analysis_time, invalid_plates, health = parse_ols(ols_path)
	
	puts "current: #{current}"
	puts "batch_ext"
	puts display_bytes(batch_ext)
	puts "inj_state"
	puts display_bytes(inj_state)
	puts "server st cycle"
	puts display_bytes(server_status_cycle)
	puts "oastat"
	puts display_bytes(oastat)
	puts "last_err"
	puts last_err
	puts "auto_smplr"
	puts display_bytes(auto_smplr)
	puts "invalid_plates"
	puts display_bytes(invalid_plates)
	

	puts "in plate 1"
	puts "desc: #{plate_1[1]}"
	puts "owner: #{plate_1[2]}"
	puts "plate: #{plate_1[3]}\n#{display_bytes(plate_1[3])}"
	puts "excludes: #{display_bytes(plate_1[4])}"
	puts "holder: #{display_bytes(plate_1[5])}"
	puts "usage: #{display_bytes(plate_1[6])}"
	puts "Batchlist:"
	plate_1[0].each do |batch|
	puts batch[0]
	puts batch[1]
	puts batch[2]
	puts display_bytes(batch[3])
	puts display_bytes(batch[4])
	end

	puts "in plate 2"
	
	puts "desc: #{plate_2[1]}"
	puts "owner: #{plate_2[2]}"
	puts "plate: #{plate_2[3]}\n#{display_bytes(plate_2[3])}"
	puts "excludes: #{display_bytes(plate_2[4])}"
	puts "holder: #{display_bytes(plate_2[5])}"
	puts "usage: #{display_bytes(plate_2[6])}"
	puts "Batchlist:"
	plate_2[0].each do |batch|
	puts batch[0]
	puts batch[1]
	puts batch[2]
	puts display_bytes(batch[3])
	puts display_bytes(batch[4])
	end


