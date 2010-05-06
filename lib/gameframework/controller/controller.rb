require 'gameframework/game/event'
require 'gameframework/game/game'

module GameFramework
	class Controller
		def run
			choose_game
			show_game_state
			begin
				event = show_and_get_event(@game.view)
				begin
					@game.execute_event event
					show_game_state
				rescue StandardError => e
					puts "Invalid event. #{e} #{e.backtrace.join("\n")}"
				end			
			end until @game.end_game?
			show(@game.view)
		end
		
		def choose_game
			begin
				puts "Choose a game: "
				GameFramework::Game.available_games.each_with_index {|g, i| puts "#{i}. #{g}"}
				game = gets.chomp.to_i
				chosen = GameFramework::Game.available_games[game]
			end until chosen
			@game = chosen.send(:new, "jesus", "alvaro")
		end
		
		def show_game_state
			puts "-" * 100
			p @game
		end
		def show_and_get_event view
			show view
			puts "Type the event"
			event = gets.chomp
			id, *params = event.split(",")
			h = params.inject({}) do |hash, tuple|
				key, value = tuple.split("=")
				hash[key.to_sym] = value
				hash
			end
			Event.new id.to_sym, h
		end
		
		def show view
			p view
		end
	end
end
