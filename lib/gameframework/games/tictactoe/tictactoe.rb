require 'gameframework/game/game'
require 'gameframework/game/event'
require 'gameframework/components/state_machine'

module GameFramework
    class TicTacToe < Game
        WINNING_POSITIONS = [
            [[0,0], [1,0], [2,0]], #rows 
            [[0,1], [1,1], [2,1]],
            [[0,2], [1,2], [2,2]],
            [[0,0], [0,1], [0,2]], #cols
            [[1,0], [1,1], [1,2]],
            [[2,0], [2,1], [2,2]],

            [[0,0], [1,1], [2,2]], #diagonals
            [[2,0], [1,1], [0,2]]
        ]
        field :map, type: Hash, default: ->{  Hash[*(self.players.zip([[], []]).flatten(1))] }
        field :state, type: Symbol, default: :waiting_move


        after_initialize do
            puts "initializing tictactoe game"
            @machine = StateMachineBuilder.new.build(self, state) do 
                transition :waiting_move => :move_executed, :on => :move do |context|
                    context.execute_move
                    context.next_player!
                    fire context.end_state? ? :game_end : :game_continue
                end

                transition :move_executed => :waiting_move, :on => :game_continue
                transition :move_executed => :end, :on => :game_end
            end
        end

        def is_match_finished?
            end_state?
        end

        def state_for user
            {"map" => map}
        end

        def parse_and_validate_event event
            raise "Invalid event id" unless event.id == :move

            begin
                @x = Integer(event.params[:x])
                @y = Integer(event.params[:y])
            rescue ArgumentError
                raise "Params x and y should be integers"
            end
            puts "in validate_event: #{[@x,@y]}"
            raise "Out of bounds" if out_of_bounds(@x,@y)
            raise "Space not free" if space_not_free(@x,@y)
        end
        
        def execute_event event
            parse_and_validate_event event
            @machine.fire :move
        end
        
        def execute_move
            puts "Move: #{@x}, #{@y}"
            map[active_player] << [@x,@y]
        end

        def out_of_bounds(x,y)
            x < 0 || x > 2 || y < 0 || y > 2
        end

        def space_not_free(x,y)
            map.values.flatten(1).find {|cell| cell.eql?([x,y])}
        end

        def end_state?
            board_full? || winning_position?
        end

        def board_full?
            occupied_cells = map.inject(0) {|total, (player, cells)| total + cells.size}
            occupied_cells >= 9
        end

        def winning_position?
            map.any? {|player, cells| WINNING_POSITIONS.any? {|position| position.all? {|cell| cells.include? cell}}}
        end
    end
end
