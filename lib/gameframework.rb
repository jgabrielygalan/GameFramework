libdir = File.dirname(__FILE__)
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'gameframework/game/game'
require 'gameframework/controller/controller'

#load all available games
# games should reside in a folder under games and only have 1 rb file at that level. All other game files should be required from this one
Dir["#{libdir}/gameframework/games/*/*.rb"].each do |x| 
	puts "requiring #{File.join(File.dirname(x), File.basename(x, ".rb"))}"
	require File.join(File.dirname(x), File.basename(x, ".rb"))
end
