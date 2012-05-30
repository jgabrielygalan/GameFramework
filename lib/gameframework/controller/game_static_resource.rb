require 'gameframework'

class GameStaticResource
	def initialize app
		@app = app		
		@file_servers = {}
	end

	def get_file_server_for_key key
		root = GameFramework::Game.available_games[key].resource_path
		puts "Creating Rack::File for key [#{key}] in path #{root}"
		Rack::File.new(root)
	end

	def file_server key
		@file_servers[key] ||= get_file_server_for_key(key)
	end

	def call env
		path = env["PATH_INFO"]
		match = path.match(%r{/resources/(.*?)(/.*)})
		if match
			key = match.captures[0]
			env["PATH_INFO"] = match.captures[1]
			file_server(key).call(env)	    
		else
        	@app.call(env)
       	end
	end
end