require 'gameframework/game/game'
require 'gameframework/game/event'

module TicTacToe
	class Game < GameFramework::Game
		view_path File.expand_path(File.join(File.dirname(__FILE__), "views"))
		initial_view :map
		initial_accepted_events :move

		attr_accessor :active_player, :active_symbol, :player1, :player2 
		attr_accessor :map
		
		def initialize(player1, player2)
			@player1 = player1
			@player2 = player2
			@active_player = player1
			@active_symbol = "@"			
		 	@map = Array.new(3) {Array.new(3)}
		end
	
		def move event
			x = event.params[:x].to_i
			y = event.params[:y].to_i
			raise "Out of bounds" if out_of_bounds(x,y)
			raise "Space not free" if space_not_free(x,y)
			@map[x][y] = @active_symbol
			switch_active_player
			[:map, [:move]]
		end

		def out_of_bounds(x,y)
			x < 0 || x > 2 || y < 0 || y > 2
		end

		def space_not_free(x,y)
			@map[x][y]
		end

		def switch_active_player
			@active_player = (@active_player == @player1 ? @player2 : @player1)
			@active_symbol = (@active_symbol == "@" ? "X" : "@")
		end

		def end_state?
			(@map[0][0] && @map[0][0] == @map[0][1] && @map[0][0] == @map[0][2]) ||
			(@map[1][0] && @map[1][0] == @map[1][1] && @map[1][0] == @map[1][2]) ||
			(@map[2][0] && @map[2][0] == @map[2][1] && @map[2][0] == @map[2][2]) ||
			(@map[0][0] && @map[0][0] == @map[1][0] && @map[0][0] == @map[2][0]) ||
			(@map[1][0] && @map[0][1] == @map[1][1] && @map[0][1] == @map[2][1]) ||
			(@map[2][0] && @map[0][2] == @map[1][2] && @map[0][2] == @map[2][2]) ||
			(@map[0][0] && @map[0][0] == @map[1][1] && @map[0][0] == @map[2][2]) ||
			(@map[2][0] && @map[2][0] == @map[1][1] && @map[2][0] == @map[0][2])
		end
	end
end
