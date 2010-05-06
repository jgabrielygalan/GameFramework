require '../components/bag'

class Controller
	def run
		@game = Stronghold::Game.new("jesus", "alvaro")
		show_game_state
		begin
			current_handler = @game.current_event_handler
			view = current_handler.view
			event = show_and_get_event(view)
			begin
				next_handler = current_handler.execute_event event
				@game.current_event_handler = next_handler
				show_game_state
			rescue StandardError => e
				puts "Invalid event. #{e} #{e.backtrace.join("\n")}"
			end			
		end until @game.end_game?
		show(@game.current_event_handler.view)
	end
	def show_game_state
		puts "-" * 100
		p @game
	end
	def show_and_get_event view
		show view
		puts "Type the event"
		event = gets.chomp
		id, *params = event.split(",")
		h = params.inject({}) do |hash, tuple|
			key, value = tuple.split("=")
			hash[key.to_sym] = value
			hash
		end
		Event.new id.to_sym, h
	end
	
	def show view
		p view
	end
end

class Event
	attr_reader :id, :params
	
	def initialize id, params
		@id = id
		@params = params
	end
end

class EventHandler
	def self.inherited subclass
		subclass.instance_eval do
			@events = {}
		end
		class << subclass; self; end.instance_eval {attr_accessor :events}
	end
	
	def self.register_event eventID, method
		events[eventID] = method
	end
	
	def execute_event event
		eventID = event.id
		method = self.class.events[eventID]
		raise "No handler for event [#{eventID}]" unless method
		send method, event
	end
end

module Stronghold
	UNIT_VALUE = {"g" => 1, "o" => 2, "t" => 3}

	class Game
		attr_accessor :current_event_handler, :active_player 
		attr_accessor :resources, :action_units, :attacker_glory, :unit_pouch
		attr_accessor :defender_glory, :hourglasses, :used_glory_abilities
		
		def initialize(attacker, defender)
			@attacker = attacker
			@defender = defender
			setup_attacker
			setup_defender
			self.current_event_handler = Stronghold::InitialEventHandler.new self
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
		
		def end_game?
			self.current_event_handler.end_state?
		end
	end
	
	
	class InitialEventHandler < EventHandler
		attr_reader :view
		register_event :pass, :pass
		register_event :use, :use_unit
		
		def initialize game
			@game = game
			@game.add_resources 5
			draw_units
			@game.active_player = :attacker
			@view = "Game started. Your units for this turn are: #{@game.action_units.inspect} \n You can pass (pass) or assign 1 unit to gather resources ([t|o|g])"
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

Controller.new.run