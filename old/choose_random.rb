require 'turngame'
require 'highline/import'

module ChooseRandom
	ChooseRandomGame = TurnGame::Game.describe_game do
		number_of_players 1
		
		setup_game do |game|
			game.max_number = ask("Choose maximum number:", Integer)
			game.chosen_number = rand(game.max_number) + 1
		end
		
		ended? do |game|
			game.current_number == game.chosen_number
		end
		
		turn do |game|
			game.current_number = ask("Guess a number:", Integer)
			case
				when game.current_number > game.chosen_number
					puts "My number is lower"
				when game.current_number < game.chosen_number
					puts "My number is higher"
				else
					puts "Correct !"				
			end
		end
	end
end	

ChooseRandom::ChooseRandomGame.game_for("jesus").run