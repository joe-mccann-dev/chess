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

describe MoveValidator do
  describe '#valid_move?' do
    context 'when it is a regular move' do

      let(:initial_board) {[
        [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]), Queen.new(2, [0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
        Array.new(8) { |c| Pawn.new(2, [1, c]) },
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| Pawn.new(1, [6, c]) },
        [Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]), Queen.new(1, [7, 3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
      ]}

      context 'when regular move rules are followed' do

        subject(:board) { Board.new(initial_board) }

        it 'returns true' do
          start_row = 6
          start_col = 4
          board.assign_piece_type('e4')
          board.assign_target_variables('e4', :white)
          starting_piece = board.squares[6][4]
          result = board.valid_move?(start_row, start_col, :white, starting_piece)
          expect(result).to be(true)
        end
      end

      context 'when regular move rules are not followed' do

        subject(:board) { Board.new(initial_board) }

        it 'returns false' do
          start_row = 6
          start_col = 4
          board.assign_piece_type('e5')
          board.assign_target_variables('e5', :white)
          starting_piece = board.squares[6][4]
          result = board.valid_move?(start_row, start_col, :white, starting_piece)
          expect(result).to be(false)
        end

      end
    end

    context 'when it is an attack move' do
      let(:queen_can_capture_a_pawn) {[
          [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), EmptySquare.new([0,4]), Queen.new(2, [0, 5]), Bishop.new(2, [0,6]), EmptySquare.new([0,7])],
          [Pawn.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(2, [1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2, [1, 7])],
          [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), King.new(2, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2, 4]), EmptySquare.new([2, 5]), EmptySquare.new([2,6]), Knight.new(2, [2,7])],
          [Pawn.new(1, [3,0]), EmptySquare.new([3, 1]), Pawn.new(1, [3, 2]), EmptySquare.new([3,3]), Pawn.new(1, [3,4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), EmptySquare.new([3,7])],
          [EmptySquare.new([4, 0]), EmptySquare.new([4, 1]), Queen.new(1, [4, 2]), EmptySquare.new([4,3]), Knight.new(1, [4,4]), EmptySquare.new([4,5]), EmptySquare.new([4,6]), EmptySquare.new([4,7])],
          [EmptySquare.new([5, 0]), Pawn.new(1, [5,1]), EmptySquare.new([5,2]), Pawn.new(2, [5,3]), EmptySquare.new([5,4]), Bishop.new(1, [5,5]), EmptySquare.new([5,6]), EmptySquare.new([5,7])],
          Array.new(8) { |c| EmptySquare.new([6, c])},
          Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c])}
      ]}

      context 'when attack rules are followed' do

        subject(:board) { Board.new(queen_can_capture_a_pawn) }

        it 'returns true' do
          start_row = 4
          start_col = 2
          move = 'Qxd3'
          board.assign_piece_type(move)
          board.assign_target_variables(move, :white)
          starting_piece = board.squares[4][2]
          result = board.valid_move?(start_row, start_col, :white, starting_piece)
          expect(result).to be(true)  
        end
      end

      context 'when attack rules are not followed' do
        
        subject(:board) { Board.new(queen_can_capture_a_pawn) }

        it 'returns false' do
          start_row = 4
          start_col = 2
          move = 'Qxd5' # d5 is an empty square
          board.assign_piece_type(move)
          board.assign_target_variables(move, :white)
          starting_piece = board.squares[4][2]
          result = board.valid_move?(start_row, start_col, :white, starting_piece)
          expect(result).to be(false)
        end
      end
    end

    context 'when it is a castle move' do

      context 'when a castle is possible' do
        let(:castle_possible) {[
          [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]), Queen.new(2, [0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
          Array.new(8) { |c| Pawn.new(2, [1, c]) },
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| Pawn.new(1, [6, c]) },
          [Rook.new(1, [7, 0]), EmptySquare.new([7,1]), EmptySquare.new([7,2]), EmptySquare.new([7,3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
      ]}

        subject(:board) { Board.new(castle_possible) }

        it 'returns true' do
          start_row = 7
          start_col = 4
          move = '0-0-0'
          board.assign_piece_type(move)
          board.assign_target_variables(move, :white)
          starting_piece = board.squares[7][4]
          result = board.valid_move?(start_row, start_col, :white, starting_piece)
          expect(result).to be(true)
        end
      end

      context 'when a castle move is not possible' do
        let(:castle_impossible) {[
          [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]), Queen.new(2, [0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
          Array.new(8) { |c| Pawn.new(2, [1, c]) },
          Array.new(8) { |c| EmptySquare.new([2, c]) },
          Array.new(8) { |c| EmptySquare.new([3, c]) },
          Array.new(8) { |c| EmptySquare.new([4, c]) },
          Array.new(8) { |c| EmptySquare.new([5, c]) },
          Array.new(8) { |c| Pawn.new(1, [6, c]) },
          [Rook.new(1, [7, 0]), Queen.new(2, [7,3]), EmptySquare.new([7,2]), EmptySquare.new([7,3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
        ]}

        subject(:board) { Board.new(castle_impossible) }

        it 'returns false' do
          start_row = 7
          start_row = 7
          start_col = 4
          move = '0-0-0'
          board.assign_piece_type(move)
          board.assign_target_variables(move, :white)
          starting_piece = board.squares[7][4]
          result = board.valid_move?(start_row, start_col, :white, starting_piece)
          expect(result).to be(false)
        end
      end
    end
  end
end