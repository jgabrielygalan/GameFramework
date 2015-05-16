module GameFramework
	class PlayerList
		include Enumerable
		
		def initialize *players
			# support passing an array of players or several players
			@players = players.flatten
			@current = 0
			@last_player = false
		end
		
		def set_current_player player
			@current = @players.find_index player
		end

		def current_player
			@players[@current]
		end

		def next_player!
			@current = (@current + 1) % @players.size
			@last_player = @current == (@players.size - 1)
			current_player
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

		def to_s
			{players: @players, current: @current, last: @last_player}.to_s
		end
	end
end