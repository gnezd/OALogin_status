path = "../../testdata/rpts/Bode - AlKa - 23 - on.rpt"

rpt = File.open(path, "r")
raw = rpt.readlines
rpt.close

#(0..raw.size-1).each do |ln|
(0..20).each do |ln| #small scale test

if result = raw[ln].match(/(^\[)([\d\D]*)(\]\r\n)/) #tag?
	puts "tag: #{result.captures[1]}"
end

end
