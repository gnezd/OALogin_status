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
<<<<<<< HEAD
machines = Array.new

machines.push(Machine.new("SQ1", "path to sq1 ols"))
machines.push(Machine.new("SQ3", "path to sq3.ols"))

puts machines.class
puts machines[0].class

puts machines[0].name
puts machines[0].path
=======

sq1 = =Machine.new("SQ1", "path to sq1 ols")
puts sq1.name
puts sq1.path

>>>>>>> 30119c9503f09d4377213825d1103a7cc4cfd93d
