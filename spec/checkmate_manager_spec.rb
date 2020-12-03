require 'colorize'
require_relative '../lib/modules/display'
require_relative '../lib/modules/setup_board_variables'
require_relative '../lib/modules/adjacency_list_generator'
require_relative '../lib/modules/input_validator'
require_relative '../lib/modules/move_validator'
require_relative '../lib/modules/move_disambiguator'
require_relative '../lib/modules/castle_manager'
require_relative '../lib/modules/checkmate_manager'
require_relative '../lib/modules/cpu_move_generator'
require_relative '../lib/board'
require_relative '../lib/empty_square.rb'
require_relative '../lib/player'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/king'
require_relative '../lib/queen'
require_relative '../lib/pawn'

describe CheckmateManager do
  subject(:board) { Board.new }
  attacking_color = :white

  describe '#check_escapable?' do
    context 'when an attacked king by himself CANNOT escape check' do
      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4]) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 6]) }
      let(:other_attacker) { instance_double(Queen, symbolic_color: :white, location: [1, 7]) }

    before do
      allow(black_king).to receive(:is_a?).with(King).and_return(true)
      allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
      allow(attacking_queen).to receive(:allowed_move?).and_return(true)
      allow(other_attacker).to receive(:allowed_move?).with(attacking_queen.location[0], attacking_queen.location[1]).and_return(true)
    end
      
      it 'returns false' do
        black_in_checkmate = [
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), EmptySquare.new([0,3]), black_king, EmptySquare.new([0,5]), attacking_queen, EmptySquare.new([0,7])],
          [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), EmptySquare.new([1,3]), EmptySquare.new([1,4]), EmptySquare.new([1,5]), EmptySquare.new([1,6]), other_attacker],
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| EmptySquare.new([7, c]) }
        ]

        board.instance_variable_set(:@squares, black_in_checkmate)
        expect(board.check_escapable?(attacking_color, attacking_queen)).to be(false)
      end
    end

    context 'when an attacked king can capture attacker but doing so puts him in check' do
      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4]) }
      let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [0, 3]) }
      let(:black_pawn1) { instance_double(Pawn, symbolic_color: :black, location: [1, 3]) }
      let(:black_pawn2) { instance_double(Pawn, symbolic_color: :black, location: [1, 4]) }
      let(:black_pawn3) { instance_double(Pawn, symbolic_color: :black, location: [1, 5]) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 5]) }
      let(:other_attacker) { instance_double(Queen, symbolic_color: :white, location: [1, 7]) }

      before do
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(attacking_queen).to receive(:allowed_move?).and_return(true)
        allow(black_pawn1).to receive(:allowed_move?).and_return(false)
        allow(black_pawn2).to receive(:allowed_move?).and_return(false)
        allow(black_pawn3).to receive(:allowed_move?).and_return(false)
        allow(other_attacker).to receive(:allowed_move?).with(attacking_queen.location[0], attacking_queen.location[1]).and_return(true)
      end

      it 'returns false' do
        black_in_checkmate = [
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, attacking_queen, EmptySquare.new([0,6]), other_attacker],
          [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), EmptySquare.new([1,7])],
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| EmptySquare.new([7, c]) }
        ]

        board.instance_variable_set(:@squares, black_in_checkmate)
        expect(board.check_escapable?(attacking_color, attacking_queen)).to be(false)
      end
    end
    
    context 'when an attacked king can capture attacker' do
      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4]) }
      let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [0, 3]) }
      let(:black_pawn1) { instance_double(Pawn, symbolic_color: :black, location: [1, 3]) }
      let(:black_pawn2) { instance_double(Pawn, symbolic_color: :black, location: [1, 4]) }
      let(:black_pawn3) { instance_double(Pawn, symbolic_color: :black, location: [1, 5]) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 5]) }
      let(:other_attacker) { instance_double(Queen, symbolic_color: :white, location: [1, 7]) }

      before do
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        allow(black_king).to receive(:allowed_move?).with(attacking_queen.location[0],attacking_queen.location[1]).and_return(true)
        # need to stub move isn't allowed because attacking queen can't go to its own location
        # otherwise #opponent_pieces_can_attack_where_king_would_capture? incorrectly returns true
        allow(attacking_queen).to receive(:allowed_move?).with(attacking_queen.location[0],attacking_queen.location[1]).and_return(false)
        allow(other_attacker).to receive(:allowed_move?).and_return(false)        
      end
      it 'returns true' do
        black_can_capture_attacker = [
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, attacking_queen, EmptySquare.new([0,6]), EmptySquare.new([0,7])],
          [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), other_attacker],
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| EmptySquare.new([7, c]) }
        ]

        board.instance_variable_set(:@squares, black_can_capture_attacker)
        expect(board.check_escapable?(attacking_color, attacking_queen)).to be(true)
      end
    end

    context 'when an attacked king can block check with one of his other pieces' do
      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4]) }
      let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [0, 3]) }
      let(:black_pawn1) { instance_double(Pawn, symbolic_color: :black, location: [1, 3], allowed_move?: false) }
      let(:black_pawn2) { instance_double(Pawn, symbolic_color: :black, location: [1, 4], allowed_move?: false) }
      let(:black_pawn3) { instance_double(Pawn, symbolic_color: :black, location: [1, 5], allowed_move?: false) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 7]) }
      let(:blocking_rook) { instance_double(Rook, symbolic_color: :black, location: [3, 6], allowed_move?: true)}
      
      before do
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        allow(attacking_queen).to receive(:allowed_move?).with(attacking_queen.location[0],attacking_queen.location[1]).and_return(false)
        allow(black_king).to receive(:allowed_move?).with(attacking_queen.location[0],attacking_queen.location[1]).and_return(false)
        allow(blocking_rook).to receive(:allowed_move?).and_return(true)
      end
      it 'returns true' do
        rook_can_block_check = [
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, EmptySquare.new([0, 5]), EmptySquare.new([0,6]), attacking_queen],
          [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), EmptySquare.new([1,7])],
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| c == 6 ? blocking_rook : EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| EmptySquare.new([7, c]) }
        ]
        board.instance_variable_set(:@squares, rook_can_block_check)
        expect(board.check_escapable?(attacking_color, attacking_queen)).to be(true)
      end
    end

    context 'when an attacked king can capture the attacker with one of his other pieces' do

    end
  end
end

# describe CheckmateManager do
#   describe '#check_escapable' do

#     context 'when an attacked king can block check with one of the other pieces' do
#       # white attacking black king with 3 queens, but black can block check with his queen
#       row0 = [ EmptySquare.new([0, 0]), Queen.new(1, [0, 1]), EmptySquare.new([0, 2]), EmptySquare.new([0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ]
#       row1 = [ Queen.new(1, [1, 0]), EmptySquare.new([1, 1]), EmptySquare.new([1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2,[1, 7]) ]
#       row2 = Array.new(8) { |c| EmptySquare.new([2, c]) }
#       # black queen at row3 column0 can block check
#       row3 = Array.new(8) { |c| c == 0 ? Queen.new(2, [3, c]) : EmptySquare.new([3, c]) }
#       row4 = Array.new(8) { |c| c == 3 ? Queen.new(1, [4, c]) : EmptySquare.new([4, c]) }
#       row5 = Array.new(8) { |c| EmptySquare.new([5, c]) }
#       row6 = Array.new(8) { |c| c == 4 ? EmptySquare.new([6, c]) : Pawn.new(1, [6, c]) }
#       row7 = [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]), EmptySquare.new([7, 3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
#       escapable_check_squares = [row0, row1, row2, row3, row4, row5, row6, row7]

#       subject(:board) { Board.new(escapable_check_squares) }
#       it 'returns true' do
#         player_color = :white
#         attacker = board.squares[0][1]
#         expect(board.check_escapable?(player_color, attacker)).to be(true)
#       end
#     end

#     context 'when an attacked king can capture the attacker with of his other pieces' do
#       row0 = [ EmptySquare.new([0, 0]), Queen.new(1, [0, 1]), EmptySquare.new([0, 2]), EmptySquare.new([0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ]
#       row1 = [ Queen.new(1, [1, 0]), EmptySquare.new([1, 1]), EmptySquare.new([1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2,[1, 7]) ]
#       row2 = Array.new(8) { |c| EmptySquare.new([2, c]) }
#       # black queen at row3 column0 can block check
#       row3 = Array.new(8) { |c| c == 0 ? Queen.new(2, [3, c]) : EmptySquare.new([3, c]) }
#       row4 = Array.new(8) { |c| c == 3 ? Queen.new(1, [4, c]) : EmptySquare.new([4, c]) }
#       row5 = Array.new(8) { |c| EmptySquare.new([5, c]) }
#       row6 = Array.new(8) { |c| c == 4 ? EmptySquare.new([6, c]) : Pawn.new(1, [6, c]) }
#       row7 = [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]), EmptySquare.new([7, 3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
#     end
#   end
# end