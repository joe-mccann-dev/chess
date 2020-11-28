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
  describe '#check_escapable' do

    context 'when an attacked king cannot escape check' do
      # white attacking black king with 3 queens, black king cannot capture his way out of check
      row0 = [ EmptySquare.new([0, 0]), Queen.new(1, [0, 1]), EmptySquare.new([0, 2]), EmptySquare.new([0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ]
      row1 = [ Queen.new(1, [1, 0]), EmptySquare.new([1, 1]), EmptySquare.new([1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2,[1, 7]) ]
      row2 = Array.new(8) { |c| EmptySquare.new([2, c]) }
      row3 = Array.new(8) { |c| EmptySquare.new([3, c]) }
      row4 = Array.new(8) { |c| c == 3 ? Queen.new(1, [4, c]) : EmptySquare.new([4, c]) }
      row5 = Array.new(8) { |c| EmptySquare.new([5, c]) }
      row6 = Array.new(8) { |c| c == 4 ? EmptySquare.new([6, c]) : Pawn.new(1, [6, c]) }
      row7 = [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]), EmptySquare.new([7, 3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
      checkmate_arrangement_squares = [row0, row1, row2, row3, row4, row5, row6, row7]

      subject(:board) { Board.new(checkmate_arrangement_squares) }      
      it 'returns false' do
        player_color = :white
        attacker = board.squares[0][1]
        expect(board.check_escapable?(player_color, attacker)).to be(false)
      end
    end

    context 'when an attacked king can block check with one of the other pieces' do
      # white attacking black king with 3 queens, but black can block check with his queen
      row0 = [ EmptySquare.new([0, 0]), Queen.new(1, [0, 1]), EmptySquare.new([0, 2]), EmptySquare.new([0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ]
      row1 = [ Queen.new(1, [1, 0]), EmptySquare.new([1, 1]), EmptySquare.new([1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2,[1, 7]) ]
      row2 = Array.new(8) { |c| EmptySquare.new([2, c]) }
      # black queen at row3 column0 can block check
      row3 = Array.new(8) { |c| c == 0 ? Queen.new(2, [3, c]) : EmptySquare.new([3, c]) }
      row4 = Array.new(8) { |c| c == 3 ? Queen.new(1, [4, c]) : EmptySquare.new([4, c]) }
      row5 = Array.new(8) { |c| EmptySquare.new([5, c]) }
      row6 = Array.new(8) { |c| c == 4 ? EmptySquare.new([6, c]) : Pawn.new(1, [6, c]) }
      row7 = [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]), EmptySquare.new([7, 3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
      escapable_check_squares = [row0, row1, row2, row3, row4, row5, row6, row7]

      subject(:board) { Board.new(escapable_check_squares) }
      it 'returns true' do
        player_color = :white
        attacker = board.squares[0][1]
        expect(board.check_escapable?(player_color, attacker)).to be(true)
      end
    end

    context 'when an attacked king can capture the attacker with of his other pieces' do
      row0 = [ EmptySquare.new([0, 0]), Queen.new(1, [0, 1]), EmptySquare.new([0, 2]), EmptySquare.new([0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ]
      row1 = [ Queen.new(1, [1, 0]), EmptySquare.new([1, 1]), EmptySquare.new([1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2,[1, 7]) ]
      row2 = Array.new(8) { |c| EmptySquare.new([2, c]) }
      # black queen at row3 column0 can block check
      row3 = Array.new(8) { |c| c == 0 ? Queen.new(2, [3, c]) : EmptySquare.new([3, c]) }
      row4 = Array.new(8) { |c| c == 3 ? Queen.new(1, [4, c]) : EmptySquare.new([4, c]) }
      row5 = Array.new(8) { |c| EmptySquare.new([5, c]) }
      row6 = Array.new(8) { |c| c == 4 ? EmptySquare.new([6, c]) : Pawn.new(1, [6, c]) }
      row7 = [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]), EmptySquare.new([7, 3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
    end
  end
end