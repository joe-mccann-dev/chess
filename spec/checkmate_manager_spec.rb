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
  describe '#can_block_or_capture?' do
    context 'when an attacked king by himself cannot escape check' do

      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4]) }
      let(:white_king) { instance_double(King, symbolic_color: :white, location: [7, 4]) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 6]) }
      let(:other_queen) { instance_double(Queen, symbolic_color: :white, location: [1, 7]) }
      let(:attacking_color) { :white }
      let(:black_in_checkmate) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), EmptySquare.new([0,3]), black_king, EmptySquare.new([0,5]), attacking_queen, EmptySquare.new([0,7])],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), EmptySquare.new([1,3]), EmptySquare.new([1,4]), EmptySquare.new([1,5]), EmptySquare.new([1,6]), other_queen],
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| c == 4 ? white_king : EmptySquare.new([7, c]) }
      ]}

      subject(:board_king_cannot_escape_check) { Board.new(black_in_checkmate) }

    before do
      allow(black_king).to receive(:is_a?).with(King).and_return(true)
      allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
      allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
      allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
      allow(attacking_queen).to receive(:allowed_move?).and_return(true)
      allow(other_queen).to receive(:allowed_move?).with(attacking_queen.location[0], attacking_queen.location[1]).and_return(true)
    end
      
      it 'returns false' do
        result = board_king_cannot_escape_check.can_block_or_capture?(attacking_color, attacking_queen)
        expect(result).to be(false)
      end
    end

    context 'when an attempted capture by king results in check' do

      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4]) }
      let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [0, 3]) }
      let(:black_pawn1) { instance_double(Pawn, symbolic_color: :black, location: [1, 3], allowed_move?: false) }
      let(:black_pawn2) { instance_double(Pawn, symbolic_color: :black, location: [1, 4], allowed_move?: false) }
      let(:black_pawn3) { instance_double(Pawn, symbolic_color: :black, location: [1, 5], allowed_move?: false) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 5]) }
      let(:other_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 7]) }
      let(:attacking_color) { :white }
      let(:capture_results_in_check) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, attacking_queen, EmptySquare.new([0,6]), other_queen],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), EmptySquare.new([1,7])],
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| EmptySquare.new([7, c]) }
      ]}

      subject(:board_king_tries_to_capture) { Board.new(capture_results_in_check) }

      before do
        allow(board_king_tries_to_capture).to receive(:black_king).and_return(black_king)
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        allow(attacking_queen).to receive(:allowed_move?).and_return(true)
        allow(other_queen).to receive(:allowed_move?).with(0, 5).and_return(true)
      end

      it 'returns false' do
        result = board_king_tries_to_capture.can_block_or_capture?(attacking_color, attacking_queen)
        expect(result).to be(false)
      end
    end
    
    context 'when an attacked king can capture attacker' do

      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4]) }
      let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [0, 3]) }
      let(:black_pawn1) { instance_double(Pawn, symbolic_color: :black, location: [1, 3], allowed_move?: false) }
      let(:black_pawn2) { instance_double(Pawn, symbolic_color: :black, location: [1, 4], allowed_move?: false) }
      let(:black_pawn3) { instance_double(Pawn, symbolic_color: :black, location: [1, 5], allowed_move?: false) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 5]) }
      let(:other_queen) { instance_double(Queen, symbolic_color: :white, location: [1, 7]) }
      let(:attacking_color) { :white }
      let(:capture_does_not_result_in_check) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, attacking_queen, EmptySquare.new([0,6]), EmptySquare.new([0,7])],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), other_queen],
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| EmptySquare.new([7, c]) }
      ]}

      subject(:board_king_can_capture) { Board.new(capture_does_not_result_in_check)}

      before do
        allow(board_king_can_capture).to receive(:black_king).and_return(black_king)
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        expect(black_king).to receive(:allowed_move?).with(0, 5).and_return(true)
        expect(attacking_queen).to receive(:allowed_move?).with(0, 5).and_return(false)
        expect(other_queen).to receive(:allowed_move?).with(0, 5).and_return(false)     
      end
      it 'returns true' do
        result = board_king_can_capture.can_block_or_capture?(attacking_color, attacking_queen)
        expect(result).to be(true)
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
      let(:attacking_color) { :white }
      let(:rook_can_block_check) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, EmptySquare.new([0, 5]), EmptySquare.new([0,6]), attacking_queen],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), EmptySquare.new([1,7])],
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| c == 6 ? blocking_rook : EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| EmptySquare.new([7, c]) }
      ]}

      subject(:board_king_saved_by_rook_block) { Board.new(rook_can_block_check) }
      
      before do
        allow(board_king_saved_by_rook_block).to receive(:black_king).and_return(black_king)
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        expect(attacking_queen).to receive(:allowed_move?).with(0, 7).and_return(false)
        expect(black_king).to receive(:allowed_move?).with(0, 7).and_return(false)
      end
      it 'returns true' do
        result = board_king_saved_by_rook_block.can_block_or_capture?(attacking_color, attacking_queen)
        expect(result).to be(true)
      end
    end

    context 'when an attacked king can capture the attacker with one of his other pieces' do

      let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4], allowed_move?: true) }
      let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [0, 3]) }
      let(:black_pawn1) { instance_double(Pawn, symbolic_color: :black, location: [1, 3], allowed_move?: false) }
      let(:black_pawn2) { instance_double(Pawn, symbolic_color: :black, location: [1, 4], allowed_move?: false) }
      let(:black_pawn3) { instance_double(Pawn, symbolic_color: :black, location: [1, 5], allowed_move?: false) }
      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [0, 5]) }
      let(:other_queen) { instance_double(Queen, symbolic_color: :white, location: [0,7]) }
      let(:defending_knight) { instance_double(Knight, symbolic_color: :black, location: [2, 4], allowed_move?: true) }
      let(:attacking_color) { :white }
      let(:knight_can_capture_queen) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), black_queen, black_king, attacking_queen, EmptySquare.new([0,6]), other_queen],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), black_pawn1, black_pawn2, black_pawn3, EmptySquare.new([1,6]), EmptySquare.new([1,7])],
        Array.new(8) { |c| c == 4 ? defending_knight : EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| EmptySquare.new([7, c]) }
      ]}

      subject(:board_king_saved_by_knight_capture) { Board.new(knight_can_capture_queen) }

      before do
        allow(board_king_saved_by_knight_capture).to receive(:black_king).and_return(black_king)
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        expect(attacking_queen).to receive(:allowed_move?).with(0, 5).and_return(false)
        expect(other_queen).to receive(:allowed_move?).with(0, 5).and_return(false)
      end

      it 'returns true' do          
        result = board_king_saved_by_knight_capture.can_block_or_capture?(attacking_color, attacking_queen)
        expect(result).to be(true)
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
      let(:attacking_color) { :white }
      let(:king_cannot_escape_knight_check) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), white_queen1, EmptySquare.new([0,3]), EmptySquare.new([0,4]), EmptySquare.new([0,5]), white_queen2, EmptySquare.new([0, 7])],
        Array.new(8) { |c| EmptySquare.new([1, c]) },
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| c == 0 ? white_bishop1 : EmptySquare.new([3, c]) },
        Array.new(3) { |c| EmptySquare.new([4, c]) } + [black_king, EmptySquare.new([4, 4]), white_pawn2, EmptySquare.new([4, 6]), EmptySquare.new([4, 7])],
        Array.new(8) { |c| c == 3 ? white_pawn1 : EmptySquare.new([5, c]) },
        Array.new(8) { |c| c == 2 ? attacking_knight : EmptySquare.new([6, c]) },
        Array.new(8) { |c| c == 5 ? white_bishop2 : EmptySquare.new([7, c]) }
      ]}

      subject(:board_king_cannot_block_or_capture_knight) { Board.new(king_cannot_escape_knight_check) }

      before do
        allow(board_king_cannot_block_or_capture_knight).to receive(:black_king).and_return(black_king)
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        expect(white_queen1).to receive(:allowed_move?).with(6, 2).and_return(true)
      end

      it 'returns false' do
        result = board_king_cannot_block_or_capture_knight.can_block_or_capture?(attacking_color, attacking_knight)
        expect(result).to be(false)
      end

    end

    context 'when an attacked king is checkmate but cannot capture or block the attacking piece' do

      let(:black_king) { instance_double(King, symbolic_color: :black, location: [2, 3]) }
      let(:white_pawn) { instance_double(Pawn, symbolic_color: :white, location: [3, 3]) }
      let(:white_queen1) { instance_double(Queen, symbolic_color: :white, location: [4, 1]) }
      let(:white_queen2) { instance_double(Queen, symbolic_color: :white, location: [4, 5]) }
      let(:white_knight) { instance_double(Knight, symbolic_color: :white, location: [2, 1]) }
      let(:attacking_color) { :white }
      let(:surrounded_by_queens) {[
          Array.new(8) { |c| EmptySquare.new([0, c]) },
          Array.new(8) { |c| EmptySquare.new([1, c]) },
          [EmptySquare.new([2, 0]), white_knight, EmptySquare.new([2, 2]), black_king, EmptySquare.new([2, 4]), EmptySquare.new([2,5]), EmptySquare.new([2,6]), EmptySquare.new([2, 7])],
          Array.new(8) { |c| c == 3 ? white_pawn : EmptySquare.new([3, c]) },
          [EmptySquare.new([4,0]), white_queen1, EmptySquare.new([4,2]), EmptySquare.new([4,3]), EmptySquare.new([4,4]), white_queen2, EmptySquare.new([4,6]), EmptySquare.new(4, 7)],
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| EmptySquare.new([7, c])}
      ]}

      subject(:board_in_checkmate_cannot_capture_or_block_attacker) { Board.new(surrounded_by_queens) }

      before do
        allow(board_in_checkmate_cannot_capture_or_block_attacker).to receive(:black_king).and_return(black_king)
        allow(black_king).to receive(:is_a?).with(King).and_return(true)
        allow(black_king).to receive(:is_a?).with(EmptySquare).and_return(false)
        allow(black_king).to receive(:is_a?).with(Pawn).and_return(false)
        allow(black_king).to receive(:is_a?).with(Knight).and_return(false)
        allow(white_queen2).to receive(:allowed_move?).with(4, 5).and_return(true)
        allow(white_queen1).to receive(:allowed_move?).with(4, 5).and_return(false)
        allow(white_pawn).to receive(:allowed_move?).with(4, 5).and_return(false)
        allow(black_king).to receive(:allowed_move?).with(4, 5).and_return(false)
      end

      it 'returns false' do
        result = board_in_checkmate_cannot_capture_or_block_attacker.can_block_or_capture?(attacking_color, white_queen2)
        expect(result).to be(false)
      end
    end
  end

  describe '#other_player_in_check?' do

    let(:white_king) { instance_double(King, symbolic_color: :white, location: [7, 4] )}
    let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 1] )}

    let(:queen_puts_king_in_check) {[
      Array.new(8) { |c| c == 1 ? black_king : EmptySquare.new([0, c]) },
      Array.new(8) { |c| EmptySquare.new([1, c]) },
      Array.new(8) { |c| EmptySquare.new([2, c]) },
      Array.new(8) { |c| c == 1 ? attacking_queen : EmptySquare.new([3, c]) },
      Array.new(8) { |c| EmptySquare.new([1, c]) },
      Array.new(8) { |c| EmptySquare.new([5, c]) },
      Array.new(8) { |c| EmptySquare.new([6, c]) },
      Array.new(8) { |c| c == 4 ? white_king : EmptySquare.new([7, c])}
    ]}

    let(:queen_does_not_put_king_in_check) {[
      Array.new(8) { |c| c == 1 ? black_king : EmptySquare.new([0, c]) },
      Array.new(8) { |c| EmptySquare.new([1, c]) },
      Array.new(8) { |c| EmptySquare.new([2, c]) },
      Array.new(8) { |c| c == 1 ? attacking_queen : EmptySquare.new([3, c]) },
      Array.new(8) { |c| EmptySquare.new([1, c]) },
      Array.new(8) { |c| EmptySquare.new([5, c]) },
      Array.new(8) { |c| EmptySquare.new([6, c]) },
      Array.new(8) { |c| c == 4 ? white_king : EmptySquare.new([7, c])}
    ]}

    subject(:board) { Board.new(queen_puts_king_in_check) }

    before do
      allow(board).to receive(:white_king).and_return(white_king)
      allow(board).to receive(:black_king).and_return(black_king)
      allow(board).to receive(:mark_kings_as_not_in_check)
    end

    context 'when a move puts the opponent king in check' do

      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [3, 1]) }
      let(:attacking_color) { :white }

      it 'returns true' do
        allow(attacking_queen).to receive(:allowed_move?).with(0, 1).and_return(true)
        expect(black_king).to receive(:mark_as_in_check)
        expect(black_king).to receive(:in_check).and_return(true)
        expect(white_king).to receive(:in_check).and_return(false)
        result = board.other_player_in_check?(attacking_color)
        expect(result).to be(true)
      end

    context 'when a move does not put the opponent king in check' do

      let(:attacking_queen) { instance_double(Queen, symbolic_color: :white, location: [3, 2]) }
      let(:attacking_color) { :white }

      it 'returns false' do
        allow(attacking_queen).to receive(:allowed_move?).with(0, 1).and_return(false)
        allow(white_king).to receive(:allowed_move?).with(0, 1).and_return(false)
        expect(black_king).not_to receive(:mark_as_in_check)
        expect(black_king).to receive(:in_check).and_return(false)
        expect(white_king).to receive(:in_check).and_return(false)
        result = board.other_player_in_check?(attacking_color)
        expect(result).to be(false)
      end
    end

    end
  end

  describe '#self_in_check?' do

    context 'when a move is simulated to see if white puts itself in check' do

      let(:current_player_color) { :white }

      context 'when an attempted white move results in check' do
        let(:white_king_in_check) { instance_double(King, symbolic_color: :white, location: [7, 4] ) }
        let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4] ) }
        let(:black_queen) { instance_double(Queen, symbolic_color: :black, location: [1, 4]) }
        let(:white_pawn_tries_to_capture_d6) { instance_double(Pawn, symbolic_color: :white, location: [2, 3]) }
        let(:white_puts_self_in_check) {[
          Array.new(8) { |c| c == 4 ? black_king : EmptySquare.new([0, c]) },
          Array.new(8) { |c| c == 4 ? black_queen : EmptySquare.new([1, c]) },
          Array.new(8) { |c| c == 3 ? white_pawn_tries_to_capture_d6 : EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c])},
          Array.new(8) { |c| EmptySquare.new([5, c])},
          Array.new(8) { |c| EmptySquare.new([6, c])},
          Array.new(8) { |c| c == 4 ? white_king_in_check : EmptySquare.new([7, c])}
        ]}
    
        subject(:board_king_in_check) { Board.new(white_puts_self_in_check) }

        before do
          allow(board_king_in_check).to receive(:black_king).and_return(black_king)
          allow(board_king_in_check).to receive(:white_king).and_return(white_king_in_check)
          allow(board_king_in_check).to receive(:mark_kings_as_not_in_check)
          expect(black_queen).to receive(:allowed_move?).with(7, 4).and_return(true)
          expect(black_king).not_to receive(:mark_as_in_check)
          expect(white_king_in_check).to receive(:mark_as_in_check).and_return(true)
          expect(white_king_in_check).to receive(:in_check).and_return(true)
        end

        it 'returns true' do
          result = board_king_in_check.self_in_check?(current_player_color)
          expect(result).to be(true)
        end
      end

      context 'when an attempted white move does not result in check' do

        let(:black_king) { instance_double(King, symbolic_color: :black, location: [0, 4] ) }
        let(:bishop_limiting_king_movement) { instance_double(Bishop, symbolic_color: :black, location: [2, 2])}
        let(:white_king_not_in_check) { instance_double(King, symbolic_color: :white, location: [3, 2]) }
        let(:white_does_not_put_self_in_check) {[
          Array.new(8) { |c| c == 4 ? black_king : EmptySquare.new([0, c]) },
          Array.new(8) { |c| EmptySquare.new([1, c]) },
          Array.new(8) { |c| c == 2 ? bishop_limiting_king_movement : EmptySquare.new([2, c]) },
          Array.new(8) { |c| c == 2 ? white_king_not_in_check : EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| EmptySquare.new([7, c]) },
        ]}
    
        subject(:board_king_not_in_check) { Board.new(white_does_not_put_self_in_check) }

        before do
          allow(board_king_not_in_check).to receive(:mark_kings_as_not_in_check)
          allow(board_king_not_in_check).to receive(:white_king).and_return(white_king_not_in_check)
          expect(black_king).to receive(:allowed_move?).and_return(false)
          expect(bishop_limiting_king_movement).to receive(:allowed_move?).and_return(false)
          expect(black_king).not_to receive(:mark_as_in_check)
          expect(white_king_not_in_check).not_to receive(:mark_as_in_check)
          expect(board_king_not_in_check).to receive(:check?).and_return(false)
        end

        it 'returns false' do
          result = board_king_not_in_check.self_in_check?(current_player_color)
          expect(result).to be(false)
        end
      end
      
    end
  end
end
