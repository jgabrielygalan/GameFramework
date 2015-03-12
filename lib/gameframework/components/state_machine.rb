
Transition = Struct.new :first_state, :second_state, :action

class StateMachine
	attr_reader :context, :state
	attr_reader :states, :initial_state, :transitions
	attr_reader :on_entry, :on_exit

	def initialize context, initial=:initial
		@context = context
		@initial = @state = initial
		@transitions = {}
		@pending_events = []
		@in_transition = false
	end

	def fire event
		if @in_transition
			store_event event
		else
			handle_current_and_pending_events event
		end
	end

	private

	def store_event event
		@pending_events << event
	end

	def handle_current_and_pending_events event
		do_transition event
		until @pending_events.empty?
			event = @pending_events.shift
			do_transition event
		end
	end

	# TODO: handle exceptions in the action call
	def do_transition event
		transition = @transitions[[@state, event]]
		#puts "Doing transition #{transition} for event #{event}"
		return unless transition
		@in_transition = true
		transition.action.call @context if transition.action
		@state = transition.second_state
		@in_transition = false
	end
end

class StateMachineBuilder
	def build context, initial=nil, &blk
		@state_machine = StateMachine.new context, initial
		instance_eval(&blk)
		@state_machine
	end

	def transition options, &blk
		event = options.delete :on
		first_state = options.keys.first
		second_state = options.values.first
		transition = Transition.new first_state, second_state, blk
		@state_machine.transitions[[first_state, event]] = transition
	end

	def fire event
		@state_machine.fire event
	end
end


=begin
# Context = Struct.new :value
# machine = StateMachineBuilder.new.build(Context.new(0), :a) do 
# 	transition :a => :a, :on => :event1 do |context|
# 		puts "I'm transitioning from a to a due to event1"
# 		fire :threshold_reached if context.value > 5
# 		context.value += 1
# 	end

# 	transition :a => :b, on: :threshold_reached

# #	on_entry :b do |context|
# #		puts "Entering state b"
# #		context.value = 0
# #	end
# end

events = [:e1, :e2]
machine = StateMachineBuilder.new.build("", :a) do 
	transition :a => :b, :on => :e1 do |context|
		puts "a [e1] => b"
		fire events.shuffle.first
	end

	transition :a => :c, :on => :e2 do |context|
		puts "a [e2] => c"
		fire events.shuffle.first
	end

	transition :b => :c, :on => :e1 do |context|
		puts "b [e1] => c"
		fire events.shuffle.first
	end

	transition :b => :d, :on => :e2 do |context|
		puts "b [e2] => d"
		fire events.shuffle.first
	end

	transition :c => :a, :on => :e1 do |context|
		puts "c [e1] => a"
		fire events.shuffle.first
	end

	transition :c => :d, :on => :e2 do |context|
		puts "c [e2] => d"
		fire events.shuffle.first
	end
end

#p machine
puts "firing e1"

machine.fire :e1

# TODO
- Define what's the machine behaviour if actions raise exceptions:
	- Raise an exception --> machine in invalid state
	- Catch the exception --> 
		- State remains what it was before the transition
		- State still moves to the second of the transition
		
- Define a list of actions to execute, in addition or instead of the block. For example, objects that respond to #call
	transition :a => :b, on: threshold_reached, actions: [Log, increment_counter] # or something like that

- Conditions on transition based on the context (syntax pending):
	transition :a => :b, on: threshold_reached, :if {|context| context.value < 30} do
		...
	end
=end