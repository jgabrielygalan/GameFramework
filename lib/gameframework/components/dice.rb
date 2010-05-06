class NumericDiceSet
	def self.method_missing (meth, *args)
		re = /^(throw)?_(\d+)d(\d+)$/
		match = meth.to_s.match re
		if match
			dice_num = match.captures[1].to_i
			faces = match.captures[2].to_i
			NumericDiceSet.new(dice_num, faces).throw
		else
			super
		end
	end
	
	def initialize dice_num, faces=6
		@dice_num = dice_num
		@faces = faces
	end
	
	def throw
		res = []
		@dice_num.times {res << (rand(@faces) + 1)}
		res
	end	
end

class DiceSet < NumericDiceSet
	def initialize num_dice, *syms
		super num_dice, syms.size
		@sym_map = Hash[*(1..syms.size).zip(syms).flatten]
	end

	def throw
		super.map {|num| @sym_map[num]}
	end
end
