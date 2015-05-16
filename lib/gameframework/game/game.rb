require 'ostruct'
require 'mongoid'
require 'gameframework/components/playerlist'

module GameFramework
	class Game
		include Mongoid::Document

		class << self
			attr_reader :available_games
		end
		
		field :active_player, type: String, default: -> {self.players.first}
		field :players, type: Array
		
		def for_user user
			{
				type: "match",
    			id: id,
    			active_player: active_player,
    			match_finished: is_match_finished?,
    			state: state_for(user)
   			}
		end

		def self.inherited subclass
			super # we need to call super cause Mongoid uses the inherited hook to setup SCI (_type)
			class_name = subclass.name.to_s.split("::").last
			(@available_games ||= {})[class_name] = subclass
		end

		def name 
			self.class.name.to_s.split("::").last
		end
		
		after_initialize do 
			@player_list = GameFramework::PlayerList.new *(players)
			@player_list.set_current_player active_player
			puts "after_initialize game, #{@player_list}"
		end

		def next_player!
			@player_list.next_player!
			self.active_player = @player_list.current_player
		end

		def ended?
			false
		end

		def is_active_player? user
			user && user.name == active_player
		end
	end
end
