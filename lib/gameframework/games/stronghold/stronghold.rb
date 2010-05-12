require 'gameframework/game/game'
require 'gameframework/game/event'
require 'gameframework/components/bag'

module Stronghold
	UNIT_VALUE = {"g" => 1, "o" => 2, "t" => 3}

	class Game < GameFramework::Game
		view_path File.expand_path(File.join(File.dirname(__FILE__), "views"))
		attr_accessor :active_player 
		attr_accessor :resources, :action_units, :attacker_glory, :unit_pouch
		attr_accessor :defender_glory, :hourglasses, :used_glory_abilities
		
		def initialize(attacker, defender)
			@attacker = attacker
			@defender = defender
			setup_attacker
			setup_defender
			@current_event_handler = Stronghold::Initial.new self
		end
		
		def setup_attacker
			self.attacker_glory = 10
			self.resources = 5
			self.unit_pouch = Bag.new
			60.times {self.unit_pouch << "g"}
			100.times {self.unit_pouch << "o"}
			40.times {self.unit_pouch << "t"}
			self.action_units = {"g" => 0, "o" => 0, "t" => 0}
		end

		def setup_defender
			self.defender_glory = 4
			self.used_glory_abilities = {:barricades => false, :shameful_negotiations => false, :on_last_legs => false, :open_the_dungeons => false}
			self.hourglasses = 4
		end

		def add_resources num
			@resources += num
		end
		
		def draw_unit
			unit = @unit_pouch.draw
			@action_units[unit] += 1
		end
		
		def use_unit type
			raise "No units of type #{type} are usable" if @action_units[type] <= 0
			@action_units[type] -= 1
			@hourglasses += 1
		end		
	end	

	class Initial < GameFramework::EventHandler
		register_event :start_game, :start
		default_view :start
		
		def start event
			@game.active_player = :attacker
			@game.add_resources 5
			draw_units
			Phase1.new @game
		end

		def draw_units
			14.times do 
				@game.draw_unit
			end
		end
	end

	class Phase1 < GameFramework::EventHandler
		register_event :pass, :pass
		register_event :use, :use_unit
		default_view :phase1
		
		def pass event
			Phase2.new @game
		end
		
		def use_unit event
			unit = event.params[:unit]
			value = UNIT_VALUE[unit]
			@game.use_unit unit
			@game.add_resources value
			Phase2.new @game
		end
	end
	
	class Phase2 < GameFramework::EventHandler
		default_view :phase2
		def end_state?
			true
		end
	end
end
