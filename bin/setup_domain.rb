#!/usr/bin/env ruby

require 'mongoid'

$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib"))
require 'gameframework'
require 'gameframework/game/event'
require 'gameframework/game/game'

Mongoid.load!("../config/mongoid.yml", :development)
