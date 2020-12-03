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
      let(:blocking_rook) { instance_double(Rook, symbolic_color: :black, location: [3, 6], allowed_move?: true) }
      
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
      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4], allowed_move?: true) }
      let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [0, 3]) }
      let(:black_pawn1) { instance_double(Pawn, symbolic_color: :black, location: [1, 3], allowed_move?: false) }
      let(:black_pawn2) { instance_double(Pawn, symbolic_color: :black, location: [1, 4], allowed_move?: false) }
      let(:black_pawn3) { instance_double(Pawn, symbolic_color: :black, location: [1, 5], allowed_move?: false) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 5]) }
      let(:other_attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0,7]) }
      let(:defending_knight) { instance_double(Knight, symbolic_color: :black, location: [2, 4], allowed_move?: true) }

      before do
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        allow(attacking_queen).to receive(:allowed_move?).with(attacking_queen.location[0],attacking_queen.location[1]).and_return(false)
        allow(defending_knight).to receive(:allowed_move?).and_return(true)
      end
      it 'returns true' do
        knight_can_capture_queen = [
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, attacking_queen, EmptySquare.new([0,6]), attacking_queen],
          [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), EmptySquare.new([1,7])],
          Array.new(8) { |c| c == 4 ? defending_knight : EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| EmptySquare.new([7, c]) }
        ]
        board.instance_variable_set(:@squares, knight_can_capture_queen)
        expect(board.check_escapable?(attacking_color, attacking_queen)).to be(true)
      end
    end

    context 'when an attacked king cannot block or capture piece that put him in check' do
      let(:black_king) { instance_double(King, symbolic_color: :black, location: [4, 3]) }
      let(:white_pawn1) { instance_double(Pawn, symbolic_color: :white, location: [5, 3]) }
      let(:white_pawn2) { instance_double(Pawn, symbolic_color: :white, location: [4, 5]) }
      let(:white_bishop1) {instance_double(Bishop, symbolic_color: :white, location: [3, 0]) }
      let(:white_bishop2) { instance_double(Bishop, symbolic_color: :white, location: [7, 5]) }
      let(:white_queen1) { instance_double(Queen, symbolic_color: :white, location: [0, 2]) }
      let(:white_queen2) { instance_double(Queen, symbolic_color: :white, location: [0, 6]) }
      let(:attacking_knight) { instance_double(Knight, symbolic_color: :white, location: [6, 2]) }

      before do
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        allow(white_queen1).to receive(:allowed_move?).with(6, 2).and_return(true)
        allow(attacking_knight).to receive(:allowed_move?).with(attacking_knight.location[0],attacking_knight.location[1]).and_return(false)
      end
      it 'returns false' do
        king_cannot_escape_knight_check = [
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), white_queen1, EmptySquare.new([0,3]), EmptySquare.new([0,4]), EmptySquare.new([0,5]), white_queen2, EmptySquare.new([0, 7])],
          Array.new(8) { |c| EmptySquare.new([1, c]) },
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| c == 0 ? white_bishop1 : EmptySquare.new([3, c]) },
          Array.new(3) { |c| EmptySquare.new([4, c]) } + [black_king, EmptySquare.new([4, 4]), white_pawn2, EmptySquare.new([4, 6]), EmptySquare.new([4, 7])],
          Array.new(8) { |c| c == 3 ? white_pawn1 : EmptySquare.new([5, c]) },
          Array.new(8) { |c| c == 2 ? attacking_knight : EmptySquare.new([6, c]) },
          Array.new(8) { |c| c == 5 ? white_bishop2 : EmptySquare.new([7, c]) }
        ]
        board.instance_variable_set(:@squares, king_cannot_escape_knight_check)
        expect(board.check_escapable?(attacking_color, attacking_knight)).to be(false)
      end
    end
  end
end
