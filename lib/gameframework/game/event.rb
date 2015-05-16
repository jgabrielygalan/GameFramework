module GameFramework
	class Event
		attr_reader :id, :params
	
		def initialize id, params = {}
			@id = id
			@params = indifferent_params params
		end

		def to_json *a
			{'json_class' => self.class.name, 
			 "data" => {"id" => @id, "params" => @params}}.to_json(*a)
		end

		def self.json_create o
			new(o['data']['id'].to_sym, o['data']['params'])
		end

	    # Enable string or symbol key access to the nested params hash.
	    def indifferent_params(params)
	      params = indifferent_hash.merge(params)
	      params.each do |key, value|
	        next unless value.is_a?(Hash)
	        params[key] = indifferent_params(value)
	      end
	    end

	    # Creates a Hash with indifferent access.
	    def indifferent_hash
	      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
	    end
	end
end
