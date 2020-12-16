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
require_relative '../lib/pieces/piece'
require_relative '../lib/pieces/rook'
require_relative '../lib/pieces/knight'
require_relative '../lib/pieces/bishop'
require_relative '../lib/pieces/king'
require_relative '../lib/pieces/queen'
require_relative '../lib/pieces/pawn'

describe Piece do
  describe '#allowed_move?' do
    context 'when piece is a pawn' do

      let(:initial_board) {[
        [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]),Queen.new(2, [0, 3]), King.new(2, [0, 4]),Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7])],
        Array.new(8) { |c| Pawn.new(2, [1, c]) },
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| Pawn.new(1, [6, c]) },
        [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]),Queen.new(1, [7, 3]), King.new(1, [7, 4]),Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7])]
      ]}

      let(:board) { Board.new(initial_board) }
      subject(:pawn) { board.squares[6][4] }
      context 'move is allowed' do
        it 'returns true' do
          dest_row = 4
          dest_col = 4
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'move is not allowed' do
        it 'returns false' do
          dest_row = 3
          dest_col = 4
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end

      context 'when pawn tries to move backwards' do

        let(:board_pawn_moved_two) {[
          [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]),Queen.new(2, [0, 3]), King.new(2, [0, 4]),Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7])],
          Array.new(8) { |c| Pawn.new(2, [1, c]) },
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| c == 4 ? Pawn.new(1, [4,4]) : EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| c == 4 ? EmptySquare.new([6,4]) : Pawn.new(1, [6, c]) },
          [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]),Queen.new(1, [7, 3]), King.new(1, [7, 4]),Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7])]
        ]}
        
        let(:board) { Board.new(board_pawn_moved_two) }
        subject(:pawn) { board.squares[4][4] }
        
        it 'returns false' do
          dest_row = 5
          dest_col = 4
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end

      context 'when a pawn tries an attack move on an empty square' do
        let(:board) { Board.new(initial_board) }
        subject(:pawn) { board.squares[6][4] }
        
        it 'returns false' do
          dest_row = 5
          dest_col = 5
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end

      context 'when a pawn tries an attack move on an enemy queen one diagonal away' do

        let(:board_pawn_can_attack) {[
          [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]),Queen.new(2, [0, 3]), King.new(2, [0, 4]),Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7])],
          Array.new(8) { |c| Pawn.new(2, [1, c]) },
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| c == 4 ? Pawn.new(1, [4,4]) : EmptySquare.new([4, c]) },
          Array.new(8) { |c| c == 5 ? Queen.new(2, [5, 5]) : EmptySquare.new([5, c]) },
          Array.new(8) { |c| Pawn.new(1, [6, c]) },
          [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]),Queen.new(1, [7, 3]), King.new(1, [7, 4]),Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7])]
        ]}
        
        let(:board) { Board.new(board_pawn_can_attack)}
        subject(:pawn) { board.squares[6][4] }

        before do
          start_row = 6
          start_col = 4
          dest_row = 5
          dest_column = 5
          pawn.toggle_attack_mode(board_pawn_can_attack, start_row, start_col, dest_row, dest_column)
        end

        it 'returns true' do
          dest_row = 5
          dest_col = 5
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'when a pawn tries an attack move on an enemy queen two diagonals away' do

        let(:board_pawn_cannot_attack) {[
          [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]),Queen.new(2, [0, 3]), King.new(2, [0, 4]),Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7])],
          Array.new(8) { |c| Pawn.new(2, [1, c]) },
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| c == 5 ? Queen.new(1, [4,c]) : EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| Pawn.new(1, [6, c]) },
          [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]),Queen.new(1, [7, 3]), King.new(1, [7, 4]),Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7])]
        ]}

        let(:board) { Board.new(board_pawn_cannot_attack) }
        subject(:pawn) { board.squares[6][4] }

        before do
          start_row = 6
          start_col = 4
          dest_row = 4
          dest_column = 5
          pawn.toggle_attack_mode(board_pawn_cannot_attack, start_row, start_col, dest_row, dest_column)
        end

        it 'returns false' do
          dest_row = 4
          dest_col = 5
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end
    end
  end
end