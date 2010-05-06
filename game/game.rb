class Game
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