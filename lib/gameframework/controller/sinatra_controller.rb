require 'gameframework'
require 'gameframework/game/event'
require 'gameframework/game/game'
require 'gameframework/domain/user'
require 'sinatra/base'
require 'sinatra/json'

module GameFramework
	class SinatraController < Sinatra::Base
		helpers do 
			def resource_path resource
				File.join('resources', session['game_key'], resource)
			end
		end

		configure do
			enable :logging
		end

		before do
    		auth =  Rack::Auth::Basic::Request.new(request.env)
    		if auth.provided? and auth.basic? and auth.credentials    			
    			@user = User.authenticate *auth.credentials
    			puts "Authenticated user: #{@user.inspect}"
    		end
    		#halt 401 unless @user
		end

		before '/games/:name/?:id?/?*' do |name,id,_|
			@game_class = GameFramework::Game.available_games[name]
			halt 404, "Game #{name} not found" unless @game_class
			if id
				@game = @game_class.find id
				halt 404, "Match not found" unless @game
			end
		end

		get '/' do
			redirect '/games'
		end

		get '/games' do
			games = GameFramework::Game.available_games.map {|name,_| {id: name, name: name, uri: uri("/games/#{name}")}}
			json games: games
		end

		get '/games/:name' do |name|
			matches = @game_class.each.to_a
			json matches.map {|m| {player1: m.player1, player2: m.player2, active: m.active_player, uri: uri("/games/#{name}/#{m.id}")}}
		end

		post '/games/:name' do |name|
			game = @game_class.create!({player1: "jesus", player2: "alicia"})
			redirect "/games/#{name}/#{game.id}"
		end
		
		get '/games/:name/:id' do |name, _|
			json game_for(@game, @user, name)
		end

		post '/games/:name/:id/event' do |name, _|
			halt 403, "Not your turn" unless @user.id == @game.active_player
			request.body.rewind
  			data = JSON.parse request.body.read
			puts "received event #{data}"
			
			halt 400, "Event body is empty" if data.nil? 

			e = get_event(data)
			@game.execute_event e
			@game.save
			json game_for(@game, @user, name)
		end

		def get_event data
			id = data.delete "id"
			Event.new id.to_sym, data
		end

		def game_for game, user, name
			game_data = {game: game.for_user(user)}
			if game.is_active_player? user
				game_data[:uri] = uri("/games/#{name}/#{game.id}/event")
			end
			game_data
		end
	end
end