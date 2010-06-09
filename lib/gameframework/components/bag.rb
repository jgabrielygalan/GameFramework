class Bag
	def initialize
		@storage = Hash.new {|h,k| h[k] = 0}
		@total = 0
	end
	
	def put obj
		@storage[obj] += 1
		@total += 1
		self
	end
	
	alias :<< :put
	
	def draw
		index = rand(@total)
		element = @storage.find do |k,v|
			index < v || (index -= v; false)
		end
		@storage[element.first] -= 1
		@total -= 1
		element.first
	end

	def draw_of_type type
		count = @storage[type]
		if count > 0
			@storage[type] -= 1
			@total -= 1
			type
		else
			nil
		end
	end

	def empty?
		@total == 0
	end
	
	def size
		@total
	end
	
	def count type
		@storage[type]
	end
end
