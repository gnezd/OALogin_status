puts ARGV[0..3].any? {|a| a == nil}

ARGV[0..3].each do |a|
	puts a
	puts a.class
	puts a==nil
end

puts ARGV[0..3].class

