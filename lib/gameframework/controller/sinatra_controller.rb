require 'gameframework'
require 'gameframework/game/event'
require 'gameframework/game/game'
require 'gameframework/domain/user'
require 'sinatra/base'
require 'sinatra/json'

module GameFramework
	class SinatraController < Sinatra::Base
		configure do
			enable :logging
		end

		helpers do 
			def authenticate!
				token = params["token"]
				halt 401 unless token
				@user = User.find_by(token: token)
				halt 401 unless @user
			end
		end

		before '/games/:name/?:id?/?*' do |name,id,_|
			@game_class = GameFramework::Game.available_games[name]
			halt 404, "Game #{name} not found" unless @game_class
			if id
				@game = @game_class.find id
				halt 404, "Match not found" unless @game
			end
		end

		post '/auth' do 
   			user = User.authenticate params["username"], params["password"]
   			if user
				json token: user.token, success: true
			else 
				halt 401
			end
		end

		get '/games' do
			json GameFramework::Game.available_games.map {|name,_| {id: name, name: name, rels: {uri: uri("/games/#{name}")}}}
		end

		get '/matches' do
			authenticate!
			json GameFramework::Game.each.to_a.map {|m| game_for(m, @user)}
		end

		get '/games/:name' do |name|
			authenticate!
			matches = @game_class.each.to_a
			json matches.map {|m| {players: m.players, active: m.active_player, rels: {uri: uri("/games/#{m.name}/#{m.id}")}}}
		end

		post '/games/:name' do |name|
			authenticate!
			request.body.rewind
  			data = JSON.parse request.body.read # expected JSON: {"opponent": "abcde"}
  			halt 400, "No opponent" unless data["opponent"]
  			halt 404, "Opponent doesn't exist" unless User.find_by(name: data["opponent"])
			game = @game_class.create!({players: [@user.name, data["opponent"]]})			
			json game_for(game, @user)
		end
		
		get '/games/:name/:id' do |name, _|
			authenticate!
			json game_for(@game, @user)
		end

		post '/games/:name/:id/event' do |name, _|
			authenticate!
			halt 403, "Not your turn" unless @user.id == @game.active_player
			request.body.rewind
  			data = JSON.parse request.body.read
			puts "received event #{data}"
			
			halt 400, "Event body is empty" if data.nil? 

			e = get_event(data)
			begin
				@game.execute_event e
				@game.save
				json game_for(@game, @user)
			rescue InvalidEventError => e
				halt 400, e.message
			end
		end

		get '/users' do
			json User.all.map {|u| u.name}
		end

		def get_event data
			id = data.delete "id"
			Event.new id.to_sym, data
		end

		def game_for game, user
			game_data = {data: game.for_user(user)}
			game_data[:links] = {self: uri("/games/#{game.name}/#{game.id}")}
			if game.is_active_player? user
				game_data[:links][:event] = uri("/games/#{game.name}/#{game.id}/event")

			end
			game_data
		end
	end
end

