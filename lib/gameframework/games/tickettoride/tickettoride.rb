require 'gameframework/game/game'
require 'gameframework/game/event'
require 'gameframework/components/playerlist'
require 'gameframework/components/deck'
require 'set'

module TicketToRide
	class Game < GameFramework::Game
		COLORS = %w{white black green blue yellow purple red orange}
		ACTIONS = [:draw_tickets, :draw_card, :build]
		VIEW_AND_ACTIONS = [:initial, ACTIONS]
		view_path File.expand_path(File.join(File.dirname(__FILE__), "views"))
		resource_path File.expand_path(File.join(File.dirname(__FILE__), "public"))
		initial_view :initial
		initial_accepted_events ACTIONS

		attr_accessor :players, :routes, :display, :deck, :discard 
		attr_reader :second_card, :drawn_tickets
		
		def initialize(*players)
			setup_deck_and_display
			setup_tickets
			@players = setup_players players
			setup_routes
			@end = false
		end
		
		def setup_deck_and_display
			@deck = Deck.new
			COLORS.each {|color| 14.times {@deck << Card.new(color)}}
			12.times {@deck << Card.new("locomotive")}
			@deck.shuffle!
			@display = Hash.new(0) #key: color or locomotive, value: number of cards of that type
			@discard = Hash.new(0)
			refresh_display
		end

		def refresh_display
			until card_number(@display) == 5
				card = @deck.draw
				@display[card.color] += 1
				discard_if_locomotives
			end
		end

		def card_number hash
			hash.inject(0) {|total, (k,v)| total + v}
		end

		def discard_if_locomotives
			if @display["locomotive"] >= 3
				@display.each {|color,num| @discard[color] += num}
				@display.clear
			end
		end

		def setup_tickets
			@tickets = Deck.new
			#TODO: setup the actual tickets
			10.times{@tickets << Ticket.new("Los Angeles", "Miami")}
			10.times{@tickets << Ticket.new("Seattle", "New York")}
			@tickets.shuffle!
		end

		def setup_players names
			GameFramework::PlayerList.new(names.map do |name|
				player = Player.new name
				4.times {player.take_card @deck.draw}
				3.times {player.take_ticket @tickets.draw}
				player
			end)
		end
		
		def setup_routes
			@routes = ::Set.new
			# TODO: setup the actual routes
			@routes << Route.new("Los Angeles", "Dallas", "orange", 1)
			@routes << Route.new("Dallas", "Houston", "red", 1)
			@routes << Route.new("Houston", "Miami", "blue", 1)
		end

		# Game contract methods
		def ended?
			@end
		end

		# Transition methods

		def draw_tickets event
			player = @players.current_player
			@drawn_tickets = []
			3.times {@drawn_tickets << @tickets.draw}
			[:initial, [:return_tickets]]
		end

		def return_tickets event
			tickets_to_keep = event.params[:tickets]
			raise "You need to keep at least one ticket" if tickets_to_keep.nil? or tickets_to_keep.empty?
			tickets_to_keep.each do |ticket_number|
				puts "received ticket to keep: #{ticket_number}"
				@players.current_player.take_ticket @drawn_tickets[ticket_number.to_i]
			end
			@drawn_tickets = nil
			next_turn
			VIEW_AND_ACTIONS
		end

		def draw_card event
			if event.params[:deck]
				@players.current_player.take_card @deck.draw			
			else
				color = event.params[:color]
				puts "drawing card of color #{color}"
				raise "Card not found in display" unless @display[color] > 0
				raise "Cannot draw a face up locomotive as second draw action" if (@second_card && color == "locomotive")
				@players.current_player.take_card Card.new(color)
				@display[color] -= 1
				refresh_display
				@second_card = true if color == "locomotive"
			end
			if @second_card
				@second_card = nil
				next_turn
				VIEW_AND_ACTIONS
			else
				puts "setting second_card to true"
				@second_card = true
				[:initial, [:draw_card]]
			end
		end
		
		def build event
			city1 = event.params[:city1]
			city2 = event.params[:city2]
			color = event.params[:color]
			gray_with = event.params[:gray_with]
			route = @routes.find {|r| r.color == color && r.cities.include?(city1) && r.cities.include?(city2)}
			raise "No free route for cities #{city1} and #{city2} found in the map" unless route
			player = @players.current_player
			used_cards = player.build route, gray_with
			used_cards.each {|c| @discard[c] += 1}
			@routes.delete route
			next_turn
			VIEW_AND_ACTIONS
		end

		def next_turn
			player = @players.current_player
			if @end_player && @end_player == player
				@end = true
				calculate_final_score
			else 
				if player.end_condition?
					@end_player = player
				end
				@players.next_player!
			end
		end

		def calculate_final_score
			#TODO: score tickets
			#TODO: score longest route
		end
	end

	class Player
		attr_reader :name, :cards, :tickets, :trains, :routes, :score

		def initialize name
			@name = name
			@cards = Hash.new(0) # key: color or "locomotive", value: number of cards
			@tickets = []
			@trains = 45
			@routes = Set.new
			@score = 0
		end

		def take_card card
			@cards[card.color] += 1
		end

		def take_ticket ticket
			@tickets << ticket
		end

		def can_build? route, gray_with
			card_color = route.color == "gray" ? gray_with : route.color
			cards_of_color = @cards[card_color] + @cards["locomotive"]
			raise "Not enough cards for that route" if cards_of_color < route.length
			raise "Not enough trains" if @trains < route.length
			if routes.find {|r| r.city1 == route.city1 && r.city2 == route.city2}
				raise "The same player cannot build two routes between the same cities"
			end
			true
		end

		def build route, gray_with
			discard = []
			if can_build? route, gray_with
				card_color = route.color == "gray" ? gray_with : route.color
				if @cards[card_color] >= route.length
					@cards[card_color] -= route.length
					route.length.times {discard << card_color}
				else
					cards = @cards[card_color]
					@cards[card_color] = 0
					cards.times {discard << card_color}
					@cards["locomotive"] -= (route.length - cards)
					(route.length - cards).times {discard << "locomotive"}
				end
				@routes << route
				@trains -= route.length
				@score += score_for route.length
			else
				raise "Cannot build route"
			end
			discard
		end

		def end_condition?
			@trains <= 2
		end

		def score_for length
			{1 => 1, 2 => 2, 3 => 4, 4 => 7, 5 => 10, 6 => 15}[length]
		end
	end

	Card = Struct.new :color
	
	Route = Struct.new :city1, :city2, :color, :length do
		def cities
			[self.city1, self.city2]
		end

		def to_s
			"#{self.city1} - #{self.city2} (#{self.length} #{self.color})"
		end
	end

	Ticket = Struct.new :city1, :city2

end
