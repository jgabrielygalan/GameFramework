module GameFramework
	class Event
		attr_reader :event_id, :params
	
		def initialize event_id, params = {}
			@event_id = event_id
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
		
		def self.register_event event_id, method
			events[event_id] = method
		end
		
		def execute_event event
			event_id = event.event_id
			method = self.class.events[event_id]
			raise "No handler for event [#{event_id}]" unless method
			send method, event
		end
	end
end
