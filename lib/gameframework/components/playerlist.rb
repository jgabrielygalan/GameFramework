module GameFramework
	class PlayerList
		include Enumerable
		
		def initialize *players
			# support passing an array of players or several players
			@players = players.flatten
			@next_player = -1
			@last_player = false
		end
		
		def next_player
			@last_player = @next_player == (@players.size -1)
			@next_player = (@next_player + 1) % @players.length
			player = @players[@next_player]
		end	

		def is_last_player?
			@last_player
		end
		
		def opponents player
			@players - player
		end
		
		def each &blk
			@players.each &blk
		end
	end
end