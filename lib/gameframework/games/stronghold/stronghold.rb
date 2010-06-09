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
			@event_handler = Stronghold::Initial.new self
		end
		
		def setup_attacker
			@attacker_glory = 10
			@resources = 5
			@unit_pouch = Bag.new
			60.times {@unit_pouch << "g"}
			100.times {@unit_pouch << "o"}
			40.times {@unit_pouch << "t"}
			@action_units = {"g" => 0, "o" => 0, "t" => 0}
		end

		def setup_defender
			@defender_glory = 4
			@used_glory_abilities = {:barricades => false, :shameful_negotiations => false, :on_last_legs => false, :open_the_dungeons => false}
			@hourglasses = 4
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
			[Phase1.new(@game), GameFramework::Event.new(:turn_start)]
		end

	end

	class Phase1 < GameFramework::EventHandler
		register_event :pass, :pass
		register_event :use, :use_unit
		register_event :turn_start, :start
		default_view :phase1
		
		def start event
			@game.add_resources 5
			draw_units
			:player_input
		end
	
		def pass event
			[Phase2.new(@game), GameFramework::Event.new(:phase2_start)]
		end
		
		def use_unit event
			unit = event.params[:unit]
			value = UNIT_VALUE[unit]
			@game.use_unit unit
			@game.add_resources value
			[Phase2.new(@game), GameFramework::Event.new(:phase2_start)]
		end

		def draw_units
			14.times do 
				@game.draw_unit
			end
		end
	end
	
	class Phase2 < GameFramework::EventHandler
		register_event :phase2_start, :start
		default_view :phase2
		
		def start event
		end
	
		def end_state?
			true
		end
	end
end
