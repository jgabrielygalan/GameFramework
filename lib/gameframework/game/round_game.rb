module GameFramework
	class RoundGame < Game
		attr_accessor :round

		class << self
			attr_reader :round_hooks
		end

		def self.round_hook &blk
			(@round_hooks ||= []) << blk
		end

		def execute_round_hooks
			self.round_hooks.each {|hook| hook.call(@round)}
		end

		def next_round
			(@round ||= 0) += 1
			execute_round_hooks
		end

	end
end