require 'ostruct'

require 'components/playerlist'
require 'components/deck'

module TurnGame
	class Game
		attr_reader :players
		
		def self.describe_game &blk
			game_class = Class.new(OpenStruct) do 
				class << self
					attr_reader :setup_game_proc, :setup_player_proc, :ended_proc, :turn_proc
					
					def method_missing sym, *args, &blk
						p [self,sym, args, blk]
						if @methods
							@methods[sym] = &blk
						else
							super
						end
					end
					
					def number_of_players min, max = min
						@num_player_range = (min..max)
					end
					
					def setup_game &blk
						@setup_game_proc = blk
					end
					
					def setup_player &blk
						@setup_player_proc = blk
					end

					def ended? &blk
						@ended_proc = blk
					end
					
					# TODO: turn, round, phase definition.
					# define possible modes (player turn = all phases or turn/phase => all players)
					# based on modes, define appropriate methods
					
					#proof of concept
					def turn &blk
						@turn_proc = blk
					end

					def game_for  *players
						#initialize undefined procs to noop, to avoid checking for nil values when calling each proc
						%w{setup_game_proc setup_player_proc ended_proc turn_proc}.each do |var| 
							instance_variable_get("@#{var}") || (puts "setting #{var} to noop proc"; instance_variable_set("@#{var}", lambda{}))
						end
						#setup an empty hash for defining custom methods on the instance
						@methods = {}
						#p(instance_variables.inject({}) {|h, var| h.merge({var => instance_variable_get(var)})})
						players = players.flatten
						raise Exception, "Invalid number of players. Supported: #{@num_player_range.min} - #{@num_player_range.max}" unless @num_player_range.include? players.size 
						instance = self.new *players						
						# TODO: define methods catched in method_missing when describing the game, as instance methods of the game class.
						#@methods.each {|sym, blk| instance.send(:define_method
					end
				end
				
				def initialize *players
					super()
					@players = PlayerList.new players.map {|p| Player.new p}
				end
				
				def run
					puts "setting up the game"
					self.class.setup_game_proc[self]
					puts "setting up the players"
					@players.each {|player| self.class.setup_player_proc[self,player]}
					puts "starting the game"
					until self.class.ended_proc[self]
						self.class.turn_proc[self]
					end
				end
			end
			game_class.instance_eval &blk
			puts "Game described"
			puts ("-" * 80)
			game_class
		end
	end

	class Player < OpenStruct
		def initialize name
			super("__id__" => name)
		end
	end
end
