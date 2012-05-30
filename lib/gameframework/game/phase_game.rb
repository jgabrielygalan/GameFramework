require_relative 'round_game'

module GameFramework
	# Requires child classes to implement method player_list that returns a GameFramework::PlayerList
	# that holds the players in turn order
	class PhaseGame < RoundGame
		def self.phases *phases
			@phases = Array(phases)			
		end

		def next_turn
			(@turn ||= 0) += 1
			player_list.next_player
			execute_turn_hooks
			next_phase if player_list.is_last_player?
		end

		def next_phase

		end

	end
end