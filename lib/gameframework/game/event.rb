module GameFramework
	class Event
		attr_reader :event_id, :params
	
		def initialize event_id, params = {}
			@event_id = event_id
			@params = params
		end
	end

	class EventHandler
		attr_reader :view, :model
		
		def initialize game
			@game = game
			@model = Model.new
			@model[:game] = @game
			@view = self.class.default_view
			puts "event handler #{self.class} initialized with #{@game}, #{@model}, #{@view}"
		end

		def execute_event event
			event_id = event.event_id
			method = self.class.events[event_id]
			raise "No handler for event [#{event_id}]" unless method
			send method, event
		end

		def end_state?
			false
		end

		def self.inherited subclass
			subclass.instance_eval do
				@events = {}
			end
			class << subclass; self; end.instance_eval {attr_accessor :events}
		end
		
		def self.register_event event_id, method
			events[event_id] = method
		end
		
		def self.default_view view=nil
			if view
				@default_view = view
			end
			@default_view
		end		
	end
	
	class Model
		def []=(key, value)
			instance_variable_set("@#{key}".to_sym, value)
		end
		
		def get_binding
			binding
		end
	end
end
