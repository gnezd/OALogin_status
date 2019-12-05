require './lib.rb'

def get_machine(sqnum)

	output = String.new
	if sqnum.class == Fixnum
		path = "/home/pi/Desktop/mount_points/sq#{sqnum}_c/MassLynx/OALogin/Batchdb/"
		ols_path = "#{path}Status.ols"
	else
		ols_path = sqnum
	end
#	if sqnum == 3; ols_path = "./1847.ols" end
	begin
	ols_updtime = File.mtime(ols_path)
	plate_1, plate_2, current, batch_ext, inj_state, server_status_cycle, oastat, last_err, auto_smplr, analysis_time, invalid_plates, health = parse_ols(ols_path)
	(0..plate_2[0].length-1).each do |i| #add spice to position
		plate_2[0][i][3][0..3] = "\x02\0\0\0"
	end
	batchlist = plate_1[0] + plate_2[0]
	batchlist.sort! {|a, b| a[2] <=> b[2]}

	deg=0
	(0..batchlist.length-1).each do |i| #catch degeneracy when cross plate
		if batchlist[i][1] == batchlist[i-1][1] && i > 1
			deg += 1
		end
	end
	rescue
		health = "FALSE"
	end


	if health == "FALSE"
	output += "<div class=\"machinebox_red\"><table class=\"machinetable\" id =\"sq#{sqnum}\">\n<p class=\"m_table_title\">SQD#{sqnum} Queue:</p>\n"
		output += "<p style=\"color: red;\">Not running properly.</p>\n"
	else 
		output += "<div class=\"machinebox\"><table class=\"machinetable\" id =\"sq#{sqnum}\">\n<p class=\"m_table_title\">SQD#{sqnum} Queue:</p>\n"
	if batchlist.length == 0
		output += "<p>Machine has an empty Queue.</p>\n"
	end
	end
		#report the queue
		output += "<p> #{batchlist.length-deg} job"
		output += "s" if batchlist.length-deg > 1
		mins = (analysis_time/60).to_int 
		output += " in the queue, time needed: "
		output += "#{mins} mins and " if mins > 0
		output += "#{(analysis_time.to_int%60)} seconds.</p>
		<tr class=\"first_row\">
		<td nowrap class =\"first_row\">Job name</td>
		<td nowrap class =\"first_row\">Time submitted</td>
		<td nowrap class =\"first_row\">Locations</td>
		<td nowrap class =\"first_row\">Method</td>
		<td nowrap class =\"first_row\">Time(min)</td>
		<td nowrap class =\"first_row\">Priority / Night queue</td></tr>"
#batchlist loop
		batchlist.each do |batch|
			output += "<tr #{'id ="current"' if batch[1] == current}><td nowrap>#{batch[1]}</td>
			<td nowrap class=\"internal\">#{batch[2]}</td>"
			if batch[3].length == 12 #if in the plate
			positions = "Plate #{batch[3][0..3].unpack('l')[0].to_s} ##{batch[3][4..7].unpack('l')[0].to_s}"
			if batch[3][4..7] != batch[3][8..11] #more than one?
				begin
					n_o_w = batch[3][8..11].unpack('l')[0] - batch[3][4..7].unpack('l')[0]+1 
				rescue
					n_o_w = nil
				end
					positions += "~#{batch[3][8..11].unpack('l')[0].to_s}"
			else
				n_o_w = 1
			end
			end
			output += "<td nowrap class=\"internal\">#{positions}</td>"
			lcmethod = `grep 'LCMethod=' "#{path}/#{batch[1]}.OLB"`
			lcmethod = lcmethod.split('=')[1].chomp
			output += "<td nowrap class=\"internal\">#{lcmethod}</td>"
			time_min = `grep 'AnalysisTime=' "#{path}/#{batch[1]}.OLB"`
			time_min = time_min.split('=')[1].chomp.to_f
			if time_min == nil
				time_min = 0
			end
			output += "<td nowrap class=\"internal\">#{time_min * n_o_w if n_o_w.class != NilClass}</td>"
			
			output += "<td nowrap class=\"internal\">" #priority / night queue
			if batch[4].unpack('l')[0] != 0
				output += "Y / "
			else
				output += "- / "
			end
			eco_sched = `grep 'EconomyScheduling=' "#{path}/#{batch[1]}.OLB"`.split('=')[1].to_i
			if eco_sched == 1
				output += "Y"
			else
				output += "-"
			end
 
				
			output +=  "</td></tr>"
		end

#end batchlist loop



	output += "</table><p>OALogin last sign of life detected at #{ols_updtime}</p>\n</div>"
	
	return output

end


#---main
html_path = "/var/www/html/stat.html"
output = <<-EOHeader
<head>
<title>MoBiAS Open Access LCMS Queue monitor</title>
<link rel="stylesheet" type="text/css" href="ui.css">
<meta http-equiv="refresh" content="30">
</head>

<body>
<!--header before-->

<div id="pagebox">
EOHeader

begin
output += get_machine(1)
rescue
	output += "<p>Cannot reach SQ1</p>"
end
output += get_machine(3)

output += "<p>Page updated at #{Time.now}</p></div>"
fo = File.open(html_path, "w")
fo.puts output
fo.close
#puts output
