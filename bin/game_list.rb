$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib"))
require 'gameframework'

puts GameFramework::Game.available_games
