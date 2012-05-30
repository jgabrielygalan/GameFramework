$LOAD_PATH.unshift File.expand_path(File.join(File.dirname(__FILE__), "../../../lib"))
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'gameframework/controller/sinatra_controller'
require 'game_static_resource'      

use GameStaticResource 
run GameFramework::SinatraController