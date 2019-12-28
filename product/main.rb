require './lib.rb'
require '../engineering/rpt_parse/rpt_parse_lib.rb'
require './settings.rb'
require 'open3'

def get_machine(ols_path)
	output = String.new
	
	#check ols_path
	if ols_path =~/\/sq\d_c\/[\s\S]*\/Status.ols$/
		sqnum = ols_path.split('/sq')[1].split('_c/')[0].to_i #MoBiAS name setup
		path = ols_path.split('Status.ols')[0]
	else #not standard MoBiAS environment, probably testing
		sqnum = "UNDEF"
		path = ols_path[0..(ols_path =~/\/[^\/]*$/)] # find the directory ... is this somewhat wheel inventing? whatever.
	end

	begin
	ols_updtime = File.mtime(ols_path)
	response = `cp "#{ols_path}" ./ols` #make a copy of the ols to avoid possible locking of the file
	plate_1, plate_2, current, batch_ext, inj_state, server_status_cycle, oastat, last_err, auto_smplr, analysis_time, invalid_plates, health = parse_ols("./ols")
	(0..plate_2[0].length-1).each do |i| #Set vial position - plate # to 2 if it's from plate 2
		plate_2[0][i][3][0..3] = "\x02\0\0\0"
	end
	batchlist = plate_1[0] + plate_2[0]
	batchlist.sort! {|a, b| a[2] <=> b[2]} #sort with submission time

	deg=0
	(0..batchlist.length-1).each do |i| #catch degeneracy when cross plate
		if batchlist[i][1] == batchlist[i-1][1] && i > 1
			deg += 1
		end
	end

	rescue
		puts "Sth went wrong during ols file reading"
		health = "FALSE"
	end


	if health == "FALSE"
	output += "<div class=\"machinebox_red\"><table class=\"machinetable\" id =\"sq#{sqnum}\">\n<p class=\"m_table_title\">SQD#{sqnum}</p>\n"
		output += "<p style=\"color: red;\">Not running properly.</p>\n"
	else 
		output += "<div class=\"machinebox\"><table class=\"machinetable\" id =\"sq#{sqnum}\">\n<p class=\"m_table_title\">SQD#{sqnum}</p>\n"
	if batchlist.length == 0
		output += "<p>Machine has an empty queue.</p>\n"
	end
	end # if healthy

		#report the queue
		if batchlist.length-deg == 1
			output += "<p> Has one job"
		else
			output += "<p> Has #{batchlist.length-deg} jobs"
		end #Job number cases
		mins = (analysis_time/60).to_int 
		output += " in the queue, time needed: "
		output += "#{mins} mins and " if mins > 0
		output += "#{(analysis_time.to_int%60)} seconds.</p>"
		output +="
		<tr class=\"first_row\">
		<td nowrap class =\"first_row\">Job name</td>
		<td nowrap class =\"first_row\">Time submitted</td>
		<td nowrap class =\"first_row\">Locations</td>
		<td nowrap class =\"first_row\">Method</td>
		<td nowrap class =\"first_row\">Time(min)</td>
		<td nowrap class =\"first_row\">Priority / Night queue</td></tr>"

		batchlist.each do |batch| #batchlist loop
			output += "<tr #{'id ="current"' if batch[1] == current}><td nowrap>#{batch[1]}</td>
			<td nowrap class=\"internal\">#{batch[2]}</td>"
			if batch[3].length == 12 #if in the plate and not bigger vial slots
			positions = "Plate #{batch[3][0..3].unpack('l')[0].to_s} ##{batch[3][4..7].unpack('l')[0].to_s}"
			if batch[3][4..7] != batch[3][8..11] #more than one? number_of_vials calc
				begin
					n_o_v = batch[3][8..11].unpack('l')[0] - batch[3][4..7].unpack('l')[0]+1 
				rescue
					n_o_v = nil
				end
					positions += "~#{batch[3][8..11].unpack('l')[0].to_s}"
			else
				n_o_v = 1
			end #more than one
			end #In 48 well plate

			output += "<td nowrap class=\"internal\">#{positions}</td>"
			lcmethod = `grep 'LCMethod=' "#{path}/#{batch[1]}.OLB"`
			lcmethod = lcmethod.split('=')[1].chomp
			output += "<td nowrap class=\"internal\">#{lcmethod}</td>"
			time_min = `grep 'AnalysisTime=' "#{path}/#{batch[1]}.OLB"`
			time_min = time_min.split('=')[1].chomp.to_f
			if time_min == nil
				time_min = 0
			end
			output += "<td nowrap class=\"internal\">#{time_min * n_o_v if n_o_v.class != NilClass}</td>"
			
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
		end #end batchlist loop



	output += "</table><p>OALogin last sign of life detected at #{ols_updtime}</p>\n</div>"
	
	return output

end #def get_machine

def last_5_p_curve_plot(path, svg_out)
	rpt_list = `find \"#{path}\" -maxdepth 1 -name \"*.rpt\" -mtime -6 -type f -printf '%Ts %f\n'| sort -nr|head -5|cut -d ' ' -f2-`.split("\n")
	fname_list = []
	plot_data = File.new("data", "w")
	rpt_list.each do |fname|
		rpt = OALogin_Report.new(path+fname)
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
			end # end children :
		end #end sample
	end #end report iter
		plot_data.close

	gnuplot_command =<<"END"
set terminal svg size 1000 600
set output "#{svg_out}"
set xrange [0:7]
set yrange[0:*]
set key outside
END
	gnuplot_command  << "plot 'data' index 0 with lines t '#{fname_list[0].gsub('_','\_')}'"
	(1..fname_list.size-1).each do |fname_index|
		gnuplot_command << ", '' index #{fname_index} with lines t '#{fname_list[fname_index].gsub('_','\_')}'"
	end
	
	image, s = Open3.capture2(
		"gnuplot",
		:stdin_data=> gnuplot_command, :binmode=>true)
	
end

#---main
output = <<-EOHeader
<head>
<title>#{$html_title}</title>
<link rel="stylesheet" type="text/css" href="ui.css">
<meta http-equiv="refresh" content="30">
</head>

<body>
<!--header before-->

<div id="pagebox">
EOHeader


$machines.each do |machine|

begin
	puts "acquiring machine named #{machine.name} at ols path of #{machine.path}"
	output += get_machine(machine.path)
rescue
	output += "<div class=\"machinebox_red\"><table class=\"machinetable\" id =\"#{machine.name}\">\n<p class=\"m_table_title\">#{machine.name} Canot be reached</p></div>\n"
		
end
end #end machine


output += "<p>Page updated at #{Time.now}</p></div>"
fo = File.open($html_path, "w")
fo.puts output
fo.close

last_5_p_curve_plot("/home/pi/Desktop/mount_points/sq1_e/Masslynx Projects/OALogin_rpt/","/var/www/html/sq1.svg")
last_5_p_curve_plot("/home/pi/Desktop/mount_points/sq3_e/Masslynx Projects/OALogin_reportdb/","/var/www/html/sq3.svg")
