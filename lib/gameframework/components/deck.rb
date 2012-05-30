class EmptyDeckError < IndexError
end

class DeckTooSmall < IndexError
end

# TODO: review naming convention regarding the ! in the method names
class Deck
	include Enumerable
	
	def initialize
		@deck = []
	end

	def << (item)
		insert(item, :bottom)
	end

	def draw(where=:top, which=0)
		raise EmptyDeckError, "The deck is empty" if @deck.empty?
		raise DeckTooSmall, "The deck doesn't have #{which + 1} items" if @deck.size < which + 1
		case where
			when :top
				item = @deck.delete_at(which)
			when :bottom
				item = @deck.delete_at(@deck.size - which)
			when :random
				item = @deck.delete_at(rand(@deck.size))
		end		
		item
	end
	
	def cut!(fuzzy = false)
		cutpoint = @deck.size / 2 - 1
		cutpoint = fuzzy(cutpoint) if fuzzy
		half = @deck.slice!(0..cutpoint)
		(@deck << half).flatten!
		self
	end
	
	def randomize!
		@deck = @deck.sort_by {rand}
		self
	end
	
	# TODO: make the shuffle modelling a physical shuffle
	# by a human: simple, riffle, pile, etc, instead of a 
	# randomization
	def shuffle!
		randomize!
	end
	
	# TODO: change the name, what's the word for the opposite of draw?
	def insert(item, where = :top)
		case where
			when :top
				@deck.unshift(item)
			when :bottom
				@deck << item
			when :random
				item = @deck.insert(rand(@deck.size), item)
		end		
		self
	end
	
	def to_s
		@deck.to_s
	end
	
	def each (&blk)
		@deck.each &blk
	end

	def size
		@deck.size
	end
	
	def empty?
		return @deck.empty?
	end
	

	protected 
	def fuzzy(number)
		# Deviation: 10% of the deck size (min 1)
		deviation = @deck.size / 20
		deviation = 1 if deviation == 0
		randmax = deviation * 2 + 1
		number + rand(randmax) - deviation
	end	
end

# Tests
=begin
d = Deck.new
%w[1 2 3 4 5 6 7 8 9 10].each {|x| d << x}
puts d.cut!(true).cut!(true)
puts "----------------"
3.times {
	d.randomize!.cut!.cut!.randomize!.cut!
	puts d
}

s = Deck.new
%w[1 2 3 4 5 6 7 8 9 10].each {|x| s << x}
s.each {|card| puts card}
=end
# /Tests