require 'ostruct'
require 'mongoid'
require 'components/playerlist'

module GameFramework
	class Game
		include Mongoid::Document

		class << self
			attr_reader :available_games
		end
		
		field :active_player, type: String, default: -> {self.players.first}
		field :players, type: Array
		
		def self.inherited subclass
			super # we need to call super cause Mongoid uses the inherited hook to setup SCI (_type)
			class_name = subclass.name.to_s.split("::").last
			(@available_games ||= {})[class_name] = subclass
		end

		def name 
			self.class.name.to_s.split("::").last
		end
		
		after_initialize do 
			@player_list = GameFramework::PlayerList.new *(players.shuffle)
		end

		def next_player!
			@player_list.next_player!
			self.active_player = @player_list.current_player
		end

		def ended?
			false
		end
	end
end
