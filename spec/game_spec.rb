require 'colorize'
require_relative '../lib/modules/display'
require_relative '../lib/modules/setup_board_variables'
require_relative '../lib/modules/adjacency_list_generator'
require_relative '../lib/modules/input_validator'
require_relative '../lib/modules/move_validator'
require_relative '../lib/modules/move_disambiguator'
require_relative '../lib/modules/castle_manager'
require_relative '../lib/modules/checkmate_manager'
require_relative '../lib/modules/pawn_promotion'
require_relative '../lib/modules/en_passant_manager'
require_relative '../lib/modules/cpu_move_generator'
require_relative '../lib/modules/serializer'
require_relative '../lib/modules/game_command_manager'
require_relative '../lib/game'
require_relative '../lib/board'
require_relative '../lib/empty_square.rb'
require_relative '../lib/player'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/king'
require_relative '../lib/queen'
require_relative '../lib/pawn'

describe Game do
  describe '#checkmate?' do
    let(:attacking_color) { :white }
    context 'when opponent king is in checkmate' do
      
      let(:black_in_checkmate) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0,2]), EmptySquare.new([0,3]), King.new(2, [0, 4]), EmptySquare.new([0,5]), Queen.new(1, [0,6]), EmptySquare.new([0,7])],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), EmptySquare.new([1,3]), EmptySquare.new([1,4]), EmptySquare.new([1,5]), EmptySquare.new([1,6]), Queen.new(1, [1,7])],
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c]) }
      ]}

      subject(:board) { Board.new(black_in_checkmate) }
      subject(:game) { described_class.new(board) }

      it 'returns true' do
        attacking_queen = board.squares[0][6]
        result = game.checkmate?(attacking_color, board, attacking_queen)
        expect(result).to be(true)
      end
    end

    context 'when opponent king is not in checkmate' do
      
      let(:black_not_in_checkmate) {[
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), Bishop.new(1, [0,2]), EmptySquare.new([0,3]), King.new(2, [0, 4]), EmptySquare.new([0,5]), EmptySquare.new([0,6]), EmptySquare.new([0,7])],
          [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), EmptySquare.new([1,3]), EmptySquare.new([1,4]), EmptySquare.new([1,5]), EmptySquare.new([1,6]), Queen.new(1, [1,7])],
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| EmptySquare.new([6, c]) },
          Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c]) }
      ]}
      
      subject(:board) { Board.new(black_not_in_checkmate) }
      subject(:game) { described_class.new(board) }

      it 'returns false' do
        active_piece = board.squares[0][2]
        result = game.checkmate?(attacking_color, board, active_piece)
        expect(result).to be(false)
      end
    end

    context 'when it is stalemate' do

      let(:stalemate) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), King.new(2, [0, 4]), EmptySquare.new([0,5]), EmptySquare.new([0,6]), EmptySquare.new([0,7])],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), EmptySquare.new([1,3]), EmptySquare.new([1,4]), EmptySquare.new([1,5]), EmptySquare.new([1,6]), Queen.new(1, [1,7])],
        Array.new(8) { |c| c == 5 ? Queen.new(1, [2, 5]) : EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c]) }
    ]}
  
      subject(:board) { Board.new(stalemate) }
      subject(:game) { described_class.new(board) }
  
      it 'returns false' do
        active_piece = board.squares[2][5]
        result = game.checkmate?(attacking_color, board, active_piece)
        expect(result).to be(false)
      end
    end
  end
end