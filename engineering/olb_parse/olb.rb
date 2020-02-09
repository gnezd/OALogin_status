#!/usr/bin/ruby

require '../../product/lib.rb'

olbpath=Dir.open(ARGV[0])
Dir.chdir(olbpath)
batchlist = []

criteria = Proc.new {|filename| true &&
		     Time.now-File.mtime(filename) < 8640000
}

puts Dir.glob("*.OLB").size
Dir.glob("*.OLB").each do |file|
	next unless criteria[file]
	batchlist.push(Batch.new(file)) if file =~ /\.OLB$/
end


batchlist.each {|batch| puts batch.batch_param["BatchID"] if batch.plates.size > 1}

