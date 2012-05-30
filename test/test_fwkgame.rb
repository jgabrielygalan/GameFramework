require 'helper'
require 'minitest/unit'
MiniTest::Unit.autorun

require 'gameframework/game/game'

class TestGameBaseClass < MiniTest::Unit::TestCase	
	def setup
		GameFramework::Game.available_games.clear
	end
	
	def test_available_games_is_empty
		assert_empty GameFramework::Game.available_games
	end
	
	def test_available_games_has_one
		x = Class.new(GameFramework::Game)
		assert_equal 1, GameFramework::Game.available_games.size
		assert_equal x, GameFramework::Game.available_games.first
	end
	
	def test_available_games_has_many
		classes = (1..20).map {Class.new(GameFramework::Game)}
		assert_equal 20, GameFramework::Game.available_games.size
		games = GameFramework::Game.available_games.dup
		classes.each {|cl| assert_equal cl, games.shift}
	end

	def test_view_path_is_nil
		assert_nil GameFramework::Game.view_path
	end
end