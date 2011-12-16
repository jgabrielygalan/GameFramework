module GameFramework
	class Event
		attr_reader :id, :params
	
		def initialize id, params = {}
			@id = id
			@params = params
		end
	end

end
