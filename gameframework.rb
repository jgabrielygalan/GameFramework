libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'game/game'
require 'controller/controller'

#load all available games
# games should reside in a folder under games and only have 1 rb file at that level. All other game files should be required from this one
Dir["games/*/*.rb"].each do |x| 
	require File.join(File.dirname(x), File.basename(x, ".rb"))
end