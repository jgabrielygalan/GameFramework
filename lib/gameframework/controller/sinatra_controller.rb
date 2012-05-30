require 'gameframework'
require 'gameframework/game/event'
require 'gameframework/game/game'
require 'sinatra/base'
require 'json'
require 'cgi'

module GameFramework
	class SinatraController < Sinatra::Base
		use Rack::Session::Pool

		helpers do 
			def resource_path resource
				File.join('resources', session['game_key'], resource)
			end
			include Rack::Utils
			alias_method :h, :escape_html
		end


		configure do
			enable :logging
		end

		before '/game*' do
			@game = session['game']
			@game_key = session['game_key']
		end

		get '/' do
			@games = get_available_games
			erb :game_list
		end

		get '/create/:game_key' do |game_key|
			game_class = GameFramework::Game.available_games[game_key]
			raise "Game not found" unless game_class
			@game = game_class.send(:new, "jesus", "alicia")
			session['game'] = @game
			session['game_key'] = game_key
			redirect '/game'
		end
		
		get '/game' do
			erb @game.view, :views => @game.class.view_path
		end

		post '/game/event' do
			event = CGI.unescape request.params['event']
			puts "received event #{event}"
			data = JSON.parse(event)
			p data
			if data.nil? 
				status 400
			else
				@game.execute_event data
				if @game.ended?
					erb :game_end
				else
					erb @game.view, :views => @game.class.view_path
				end
			end
		end
		
		def get_available_games
			GameFramework::Game.available_games
		end
		
		def show_game_state
			puts "-" * 100
			#p @game
			#puts "-" * 100
		end
		
		def show_and_get_event game
			show game
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
		
		def show game
			view = game.view
			template = ERB.new(File.read("#{@view_path}#{view}.erb"), nil, "%<>")
			puts template.result(game.get_binding)
		end
	end
end


=begin
/create/:game_id
/game/event	
Public resources of a game: /resources/:game_key
=end