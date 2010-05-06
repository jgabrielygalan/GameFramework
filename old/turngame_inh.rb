require 'ostruct'

require 'components/playerlist'
require 'components/deck'

module TurnGame
	class Game
		attr_reader :players		
		
		# Allow arbitrary attributes similar to openstruct
		def method_missing sym, *args, &blk
			puts "Method missing. self.object_id is #{self.object_id}"
			p [sym, args]
			if sym.to_s =~ /=$/
				@attrs[sym] = args.first
			else
				if @attrs.has_key? sym
					@attrs[sym]
				else
					super
				end
			end
		end	
		
		# Class instance methods to define the game when inheriting:
		# class GameX < TurnGame::Game
		# 	players 2,4
		#	setup_game {|game| ...}
		#	setup_player {|game| ...}
		#	ended? {|game| ...}
		#	turn {|game| ...}
		# end
		# GameX.game_for(%w{player1 player2}).run		
		class << self
			
			#def method_missing sym, *args, &blk
			#	@methods ||= {}
			#	@methods[sym]  = blk
			#end
			
			def setup_game &blk
				if block_given?
					@setup_game = blk
				else
					@setup_game || Proc.new {}
				end
			end

			def setup_player &blk
				if block_given?
					@setup_player = blk
				else
					@setup_player || Proc.new {}
				end
			end

			def ended? &blk
				if block_given?
					@ended = blk
				else
					@ended || Proc.new {}
				end
			end

			def turn &blk
				if block_given?
					@turn = blk
				else
					@turn || Proc.new {}
				end
			end


			def players min, max = min
				@num_player_range = (min..max)
			end
						
			# TODO: turn, round, phase definition.
			# define possible modes (player turn = all phases or turn/phase => all players)
			# based on modes, define appropriate methods
						
			def game_for  *players
				players = players.flatten
				raise Exception, "Invalid number of players. Supported: #{@num_player_range.min} - #{@num_player_range.max}" unless @num_player_range.include? players.size 
				self.new *players
			end			
		end

		def initialize *players
			@attrs = {}
			@players = PlayerList.new players.map {|p| Player.new p}
		end
				
		def run
			puts "Executing run, self.object_id is: #{self.object_id}"
			puts "setting up the game"
			instance_eval   {self.class.setup_game[self] }
			puts "setting up the players"
			@players.each {|player| instance_eval {self.class.setup_player[self, player]}}
			puts "starting the game"
			until instance_eval {self.class.ended?[self]}
				instance_eval {self.class.turn[]}
			end
		end
	end

	class Player < OpenStruct
		def initialize name
			super("__id__" => name)
		end
	end
end
