module GameFramework
	class Game
		class << self
			attr_accessor :available_games
		end
		
		def self.inherited subclass
			puts "#{subclass} inherits from Game"
			(@available_games ||= []) << subclass
		end
		
		def view
			@current_event_handler.view
		end
		
		def execute_event event
			next_handler = @current_event_handler.execute_event event
			@current_event_handler = next_handler
		end

		def end_game?
			@current_event_handler.end_state?
		end
	end
end