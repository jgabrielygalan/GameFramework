class PlayerList
	include Enumerable
	
	def initialize *players
		# support passing an array of players or several players
		@players = players.flatten
		@next_player = 0
	end
	
	def next
		player = @players[@next_player]
		@next_player = (@next_player + 1) % @players.length
		player
	end	
	
	def opponents player
		@players - player
	end
	
	def each &blk
		@players.each &blk
	end
end