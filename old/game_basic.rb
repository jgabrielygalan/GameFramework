class Game
	class << self
		def players min, max = min
			@num_player_range = (min..max)
		end
	end
end