module GameFramework
	class Game
		class << self
			attr_accessor :available_games
		end
		
		def self.inherited subclass
			(@available_games ||= []) << subclass
		end
		
		def self.view_path path=nil
			if path
				@view_path = path
				@view_path += "/" unless @view_path =~ %r{/$}
			end
			@view_path
		end
		
		def view_path
			self.class.view_path
		end
		
		def model_and_view
			[@current_event_handler.model, @current_event_handler.view]
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
