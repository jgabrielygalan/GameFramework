$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib"))
$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib/gameframework"))
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'gameframework/controller/sinatra_controller'
require 'gameframework/controller/game_static_resource'      

Mongoid.load!("../config/mongoid.yml")
use GameStaticResource 
run GameFramework::SinatraController