require 'gameframework/game/game'
require 'gameframework/game/event'
require 'gameframework/components/bag'

module Stronghold
	UNIT_VALUE = {"g" => 1, "o" => 2, "t" => 3}

	class Game < GameFramework::Game
		attr_accessor :active_player 
		attr_accessor :resources, :action_units, :attacker_glory, :unit_pouch
		attr_accessor :defender_glory, :hourglasses, :used_glory_abilities
		
		def initialize(attacker, defender)
			@attacker = attacker
			@defender = defender
			setup_attacker
			setup_defender
			@current_event_handler = Stronghold::InitialEventHandler.new self
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
	
	
	class InitialEventHandler < GameFramework::EventHandler
		attr_reader :view
		register_event :pass, :pass
		register_event :use, :use_unit
		
		def initialize game
			@game = game
			@game.add_resources 5
			draw_units
			@game.active_player = :attacker
			@view = "Game started. Your units for this turn are: #{@game.action_units.inspect} \n You can pass (pass) or assign 1 unit to gather resources (use,unit=[t|o|g])"
		end
		
		def draw_units
			14.times do 
				@game.draw_unit
			end
		end
		
		def end_state?
			false
		end

		def pass event
			Phase2State.new @game
		end
		
		def use_unit event
			unit = event.params[:unit]
			value = UNIT_VALUE[unit]
			@game.use_unit unit
			@game.add_resources value
			Phase2State.new @game
		end
	end
	
	class Phase2State
		attr_reader :view
		def initialize game
			@game = game
			@view = "game ended. jesus wins!"
		end
		
		def end_state?
			true
		end
		
		def execute_event event
			raise "The game has finished. No more player actions required"
		end
	end
end