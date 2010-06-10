require 'test_helper'
require 'minitest/unit'
MiniTest::Unit.autorun

require 'gameframework/game/game'


class TestGame < MiniTest::Unit::TestCase	
	def test_available_games_is_empty
		assert_empty GameFramework::Game.available_games
	end
	
	def test_available_games_has_one
		Class.new(GameFramework::Game)
		assert_equal 1, GameFramework::Game.available_games.size
	end
end