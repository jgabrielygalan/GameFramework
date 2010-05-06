module Stronghold
	class Game
		attr_accessor :current_state
		
		def initialize(player1, player2)
			self.current_state = Stronghold::InitialState.new self
			@resources = 5
			@units = {"g" => 5, "o" => 2, "t" => 3} 
		end
		
		def add_resources num
			@resources += num
		end
		
		def use_unit type
			@units[type] -= 1
		end
		
		def end_game?
			self.current_state.kind_of? Phase2State
		end
	end
	
	class InitialState
		attr_reader :view
		
		def initialize game
			@game = game
			@view = "Game started. You received 3 trolls, 2 orcs and 5 goblins\n You can pass (pass) or assign 1 unit to gather resources ([t|o|g])"
		end
		
		def execute_event event
			case event
			when "pass"
				Phase2State.new @game
			when "t"
				@game.add_resources 3
				@game.use_unit "t"
				p @game
				Phase2State.new @game
			when "o"
				@game.add_resources 2
				@game.use_unit "o"
				p @game
				Phase2State.new @game
			when "g"
				@game.add_resources 1
				@game.use_unit "g"
				p @game
				Phase2State.new @game
			else
				raise "Invalid event"
			end
		end
	end
	
	class Phase2State
		attr_reader :view
		def initialize game
			@game = game
			@view = "game ended. jesus wins!"
		end
		
		def execute_event event
			raise "The game has finished. No more player actions required"
		end
	end
end