require 'helper'
require 'minitest/unit'
MiniTest::Unit.autorun

require 'gameframework/game/game'

class TestGameClass < MiniTest::Unit::TestCase	
	def setup
		@game_class = Class.new(GameFramework::Game)
	end

	def test_game_responds_to_methods
		assert_respond_to @game_class, :view_path
	end

	def test_view_path_initially_nil
		assert_nil @game_class.view_path
	end

	def test_view_path_settable
		@game_class.view_path "test/"
		assert_equal "test/", @game_class.view_path
	end

	def test_setting_view_path_adds_slash
		@game_class.view_path "test"
		assert_equal "test/", @game_class.view_path
	end		

	def test_setting_view_path_adds_slash_only_if_required
		@game_class.view_path "test/"
		assert_equal "test/", @game_class.view_path
	end		


	def test_two_games_different_view_paths
		game_class2 = Class.new(GameFramework::Game)
		@game_class.view_path "test"
		game_class2.view_path "test2"
		assert_equal "test/", @game_class.view_path
		assert_equal "test2/", game_class2.view_path
	end
end