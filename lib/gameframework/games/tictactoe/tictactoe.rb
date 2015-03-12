require 'gameframework/game/game'
require 'gameframework/game/event'
require 'gameframework/components/state_machine'

module TicTacToe
	class TicTacToe < GameFramework::Game
		include Mongoid::Document

		view_path File.expand_path(File.join(File.dirname(__FILE__), "views"))
		initial_view :map
		initial_accepted_events :move

		field :active_player, type: String, default: -> {self.player1}
		field :active_symbol, type: String, default: "@"
		field :player1, type: String
		field :player2, type: String
		field :map, type: Array, default: Array.new(3) {Array.new(3)}
	
		def for_user user
			{active_player: active_player, map: map}
		end

		after_initialize do
			puts "initializing tictactoe game"
			@machine = StateMachineBuilder.new.build(self, :created) do 
				transition :created => :waiting_move, :on => :start do |context|
				end

				transition :waiting_move => :move_executed, :on => :move do |context|
					context.execute_move
					fire context.end_state? ? :game_end : :game_continue
				end

				transition :move_executed => :waiting_move, :on => :game_continue
			end
			@machine.fire :start
		end

		def move event
			@x = event.params[:x].to_i
			@y = event.params[:y].to_i
			@machine.fire :move
			@result
		end
		
		def execute_move
			raise "Out of bounds" if out_of_bounds(@x,@y)
			raise "Space not free" if space_not_free(@x,@y)
			map[@x][@y] = active_symbol
			switch_active_player
			@result = [:map, [:move]]
		end

		def out_of_bounds(x,y)
			x < 0 || x > 2 || y < 0 || y > 2
		end

		def space_not_free(x,y)
			map[x][y]
		end

		def switch_active_player
			self.active_player = (active_player == player1 ? player2 : player1)
			self.active_symbol = (active_symbol == "@" ? "X" : "@")
		end

		def end_state?
			(map[0][0] && map[0][0] == map[0][1] && map[0][0] == map[0][2]) ||
			(map[1][0] && map[1][0] == map[1][1] && map[1][0] == map[1][2]) ||
			(map[2][0] && map[2][0] == map[2][1] && map[2][0] == map[2][2]) ||
			(map[0][0] && map[0][0] == map[1][0] && map[0][0] == map[2][0]) ||
			(map[1][0] && map[0][1] == map[1][1] && map[0][1] == map[2][1]) ||
			(map[2][0] && map[0][2] == map[1][2] && map[0][2] == map[2][2]) ||
			(map[0][0] && map[0][0] == map[1][1] && map[0][0] == map[2][2]) ||
			(map[2][0] && map[2][0] == map[1][1] && map[2][0] == map[0][2])
		end

		def is_active_player? user
			user && user.name == active_player
		end
	end
end
