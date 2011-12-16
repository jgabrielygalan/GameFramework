require 'ostruct'

module GameFramework
	class Game
		class << self
			attr_reader :available_games, :handlers, :initial_view, :initial_accepted_events
		end
		
		def self.inherited subclass
			(@available_games ||= []) << subclass
		end
		
		def self.view_path path=nil
			unless path.nil?
				@view_path = path
				@view_path += "/" unless @view_path.end_with?'/'
			end
			@view_path
		end

		def self.initial_view view=nil
			unless view.nil?
				@initial_view = view
			end
			@initial_view
		end

		def self.initial_accepted_events events=nil
			unless events.nil?
				@initial_accepted_events = Array(events)
			end
			@initial_accepted_events
		end

		def self.handlers
			@handlers ||= {}
		end

		def self.handler event_id, method
			handlers[event_id] = method
		end 
		
		attr_accessor :active_player
		
		def view
			@view ||= self.class.initial_view
		end

		def events
			@accepted_events ||= self.class.initial_accepted_events
		end

		def get_binding
			namespace = OpenStruct.new(:game => self)
			namespace.instance_eval {binding}
		end
		
		def execute_event event
			puts "Executing event #{event.inspect}"
			handler = get_handler event
			puts "Handler method for event is: #{handler}"
			@view, @accepted_events = send handler, event
		end

		def end_game?
			false
		end

		private

		def get_handler event
			raise "Invalid event #{event}. Acceptable events: #{events}" unless events.include? event.id
			self.class.handlers[event.id] || event.id
		end
	end
end
