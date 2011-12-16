require 'gameframework/game/game'
require 'gameframework/game/event'
require 'gameframework/components/bag'

module Stronghold
	UNIT_VALUE = {:g => 1, :o => 2, :t => 3}

	class Game < GameFramework::Game
		view_path File.expand_path(File.join(File.dirname(__FILE__), "views"))
		initial_view :initial
		initial_accepted_events :turn_start

		attr_accessor :resources, :action_units, :attacker_glory, :unit_pouch
		attr_accessor :defender_glory, :hourglasses, :used_glory_abilities
		
		def initialize(attacker, defender)
			@attacker = attacker
			@defender = defender
			setup_attacker
			setup_defender
			@end = false
		end
		
		def setup_attacker
			@attacker_glory = 10
			@resources = 5
			@unit_pouch = Bag.new
			60.times {@unit_pouch << :g}
			100.times {@unit_pouch << :o}
			40.times {@unit_pouch << :t}
			@action_units = Hash.new(0)
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
			type = type.to_sym
			raise "No units of type #{type} are usable" if @action_units[type] <= 0
			@action_units[type] -= 1
			@hourglasses += 1
		end		
		
		# Game contract methods
		def end_game?
			@end
		end

		# Transition methods

		def turn_start event
			active_player = :attacker
			add_resources 5
			14.times {draw_unit}
			[:phase1_attacker, [:pass_1, :more_resources]]
		end

		def pass_1 event
			@hourglasses += 2
			# TODO: give defender 1 stone wall
			[:phase1_defender, [:hg]]
		end
		
		def more_resources event
			unit = event.params[:unit].to_sym
			value = UNIT_VALUE[unit]
			use_unit unit
			add_resources value
			@hourglasses += 2
			# TODO: give defender 1 stone wall
			[:phase1_defender, [:hg]]
		end

		def hg event
			location = event.params[:location]
			@hourglasses -= 1
			@end = true if @hourglasses.zero?
			[:phase1_defender, [:hg]]
		end
	end
end
