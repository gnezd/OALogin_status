require '../../product/lib.rb'
require './rpt_parse_lib.rb'
require 'open3'
def select_uv_curve_plot(path, svg_out, n, name)
	rpt_list = `find \"#{path}\" -maxdepth 1 -name \"#{name}.rpt\" -mtime -6 -type f -printf '%Ts %f\n'| sort -nr|head -#{n}|cut -d ' ' -f2-`.split("\n")
	fname_list = []
	time_list = []
	injection_volume_list = []
	plot_data = File.new("data", "w")
	rpt_list.each do |fname|
		rpt = OALogin_Report.new(path+fname)
		rpt.samples.reverse.each do |sample|
			fname_list.push(sample.name)
			time_list.push(sample.acqu_time)
			injection_volume_list.push(sample.inject_volume)	
			#curve = sample.dads_curve[1]
			#max = sample.dads_max[1]
			curve = sample.tic_p
			max = sample.tic_p_max
			raise "no curve in #{sample.name}" if curve.size == 0

			curve.each do |pressure_pt|
				plot_data.puts "#{pressure_pt[0]}\t#{(pressure_pt[1].to_f)*max/100}" #real_intensity
				#plot_data.puts "#{pressure_pt[0]}\t#{(pressure_pt[1].to_f)/100}" #relative
			end
			plot_data.write("\n\n")
		end #end sample
	end #end report iter
		plot_data.close

	gnuplot_command =<<"END"
set terminal svg size 1000 600
set output "#{svg_out}"
set xrange [0:7]
set yrange[0:*]
set key outside center bottom
END
	gnuplot_command  << "plot 'data' " 	
	(0..fname_list.size-1).each do |fname_index|
		gnuplot_command << ", '' " if fname_index > 0
		gnuplot_command << "index #{fname_index} with lines t '#{fname_list[fname_index].split(/_(#{Time.now.strftime("%Y%m%d")}|#{(Time.now-86400).strftime("%Y%m%d")})/)[0].gsub('_','\_')} | #{time_list[fname_index].strftime("%R")} | #{injection_volume_list[fname_index]} uL'"
	end
	
	image, s = Open3.capture2(
		"gnuplot",
		:stdin_data=> gnuplot_command, :binmode=>true)
	
end


def select_p_curve_plot(path, svg_out, n, name)
	rpt_list = `find \"#{path}\" -maxdepth 1 -name \"#{name}.rpt\" -mtime -6 -type f -printf '%Ts %f\n'| sort -nr|head -#{n}|cut -d ' ' -f2-`.split("\n")
	fname_list = []
	time_list = []
	plot_data = File.new("data", "w")
	rpt_list.each do |fname|
		rpt = OALogin_Report.new(path+fname)
		rpt.samples.reverse.each do |sample|
			fname_list.push(sample.name)
			time_list.push(sample.acqu_time)
			sample.pressure_curve.each do |pressure_pt|
				plot_data.puts "#{pressure_pt[0]}\t#{(pressure_pt[1].to_f)*sample.max_pressure/100}"
			end
			plot_data.write("\n\n")
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
	gnuplot_command  << "plot 'data' " 	
	(0..fname_list.size-1).each do |fname_index|
		gnuplot_command << ", '' " if fname_index > 0
		gnuplot_command << "index #{fname_index} with lines t '#{fname_list[fname_index].split(/_(#{Time.now.strftime("%Y%m%d")}|#{(Time.now-86400).strftime("%Y%m%d")})/)[0].gsub('_','\_')} | #{time_list[fname_index].strftime("%R")}'"
	end
	
	image, s = Open3.capture2(
		"gnuplot",
		:stdin_data=> gnuplot_command, :binmode=>true)
	
end

select_uv_curve_plot(ARGV[0], ARGV[1], ARGV[2], ARGV[3])
