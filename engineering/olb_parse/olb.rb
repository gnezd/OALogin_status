#!/usr/bin/ruby

require '../../product/lib.rb'

olbpath=Dir.open(ARGV[0])
Dir.chdir(olbpath)
batchlist = []

criteria = Proc.new {|filename| filename=~/[\djt]\.[Oo][Ll][Bb]$/}

olbpath.children.each do |file|
	next unless criteria[file]
	batchlist.push(Batch.new(file)) if file =~ /\.OLB$/
end


batchlist.each {|batch| puts batch.batch_param["BatchID"]}

