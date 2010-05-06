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
	
	def get
		index = rand(@total)
		element = @storage.find do |k,v|
			index < v || (index -= v; false)
		end
		@storage[element.first] -= 1
		@total -= 1
		element.first
	end

	alias :draw :get
	
	def empty?
		@total == 0
	end
	
	def size
		@total
	end
end
