require 'mongoid'

Mongoid.load!("../../../config/mongoid.yml", :development)


module MyTest	
	class Test
		class << self
			attr_reader :subs
		end

		include Mongoid::Document
		field :game

		def self.inherited subclass
			super
			puts "inherited: #{subclass.name}"
			(@subs ||= []) << subclass
		end
	end
end

module MyTest
	class SubTest < MyTest::Test
		field :subgame
	end
end

module MyTest
	class SubTest2 < MyTest::Test
		field :subgame
	end
end

#MyTest::SubTest.create!({game: "a", subgame: "1"})
#MyTest::SubTest2.create!({game: "a", subgame2: "2"})

puts MyTest::Test.new.hereditary?

MyTest::Test.subs.each_with_index {|s,i| puts s.inspect; s.create!({game: "a", subgame: i})}

puts MyTest::SubTest.each.to_a.inspect
puts MyTest::SubTest2.each.to_a.inspect