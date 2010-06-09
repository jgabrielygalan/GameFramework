module GameFramework
	class Game
		attr_accessor :event_handler
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
			[@event_handler.model, @event_handler.view]
		end
		
		def execute_event event
			@event_handler.execute_event event			
		end

		def end_game?
			@event_handler.end_state?
		end
	end
end
