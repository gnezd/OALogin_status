class Machine
	def initialize(name, path)
		@ols_path = path
		@name = name
	end
	
	def path
		return @ols_path
	end

	def name
		return @name
	end
end

sq1 = =Machine.new("SQ1", "path to sq1 ols")
puts sq1.name
puts sq1.path

