flist = `find /home/ydzeng/mount_points/sq3_c/MassLynx/OALogin/Batchdb/Processed/ -name "*.OLB" -mtime 1`.split("\n")
#puts flist.length

#flist[0..1].each do |x|
x = "/home/ydzeng/queue/Bode - ycd2097tr2050.OLB"
	olb = File.open(x, "r")
	begin
	while line = olb.readline
		if line =~/^(NumberOfPlates)/; n_o_p = line.split('=')[1]; break; end
	end
	rescue EOFError
		puts "end of file"
	end

	if n_o_p == 1
		#find the plate and record (PlatePosition)
		#find the wells and record
		#push back
	else
		find plate 1
	end
#end
