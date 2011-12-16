require 'gameframework/game/event'
require 'gameframework/game/game'
require 'erb'

module GameFramework
	class Controller
		def run
			while true
				begin
				choose_game
				show_game_state
				begin
					event = show_and_get_event(@game)
					begin
						@game.execute_event event
						show_game_state
					rescue StandardError => e
						puts "Error executing event. #{e} #{e.backtrace.join("\n")}"
					end			
				end until @game.end_game?
				show(@game)
				rescue StandardError => e
					puts "Error, start a new game. #{e} #{e.backtrace.join("\n")}"
				end
			end
		end
		
		def choose_game
			begin
				puts "Choose a game: "
				GameFramework::Game.available_games.each_with_index {|g, i| puts "#{i}. #{g} [#{g.view_path}]"}
				game = gets.chomp.to_i
				chosen = GameFramework::Game.available_games[game]
			end until chosen
			@game = chosen.send(:new, "jesus", "alvaro")
			@view_path = chosen.view_path
		end
		
		def show_game_state
			puts "-" * 100
			p @game
			puts "-" * 100
		end
		
		def show_and_get_event game
			show game
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
		
		def show game
			view = game.view
			template = ERB.new(File.read("#{@view_path}#{view}.erb"), nil, "%<>")
			puts template.result(game.get_binding)
		end
	end
end
