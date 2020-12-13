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

  describe '#attack_rules_followed?' do

    let(:knight_attack_possible) {[

      [EmptySquare.new([0,0]), Knight.new(2, [0,1]), Bishop.new(2, [0, 2]), EmptySquare.new([0, 3]), EmptySquare.new([0,4]), EmptySquare.new([0,5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
      [Rook.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(1, [1, 2]), EmptySquare.new([1,3]), King.new(2, [1, 4]), EmptySquare.new([1, 5]), Pawn.new(1, [1,6]), Knight.new(1, [1,7])],
      [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), Pawn.new(1, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2,4]), EmptySquare.new([2,5]), EmptySquare.new([2,6]), Rook.new(1, [2,7])],
      [Pawn.new(2, [3, 0]), Knight.new(1, [3, 1]), EmptySquare.new([3,2]), Pawn.new(2, [3,3]), Pawn.new(1, [3, 4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), Queen.new(1, [3, 7])],
      Array.new(8) { |c| c == 5 ? Bishop.new(1, [4, 5]) : EmptySquare.new([4, c]) },
      Array.new(8) { |c| EmptySquare.new([5, c])},
      Array.new(8) { |c| EmptySquare.new(6, c) },
      Array.new(9) { |c| c == 4 ? King.new(1, [7, 4]) : EmptySquare.new([7, c])}

    ]}
    context 'when a legal attack is made' do

      subject(:board) { Board.new(knight_attack_possible) }

      before do
        move = 'Nxa7'
        board.assign_piece_type(move)
        board.assign_target_variables(move, :white)
      end

      it 'returns true' do
        start_row = 3
        start_col = 1
        starting_piece = board.squares[start_row][start_col]
        result = board.attack_rules_followed?(start_row, start_col, :white, starting_piece)
        expect(result).to be(true)
      end
    end

    context 'when an attack is illegal' do

      subject(:board) { Board.new(knight_attack_possible) }

      before do
        move = 'Nxb7'
        board.assign_piece_type(move)
        board.assign_target_variables(move, :white)
      end

      it 'returns false' do
        start_row = 3
        start_col = 1
        starting_piece = board.squares[start_row][start_col]
        result = board.attack_rules_followed?(start_row, start_col, :white, starting_piece)
        expect(result).to be(false)
      end
    end
  end
end

describe '#pawn_attack_available?' do

  context 'when move is a regular pawn attack' do

    let(:pawn_can_capture_f7) {[
      [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), EmptySquare.new([0,4]), Queen.new(2, [0, 5]), Bishop.new(2, [0,6]), EmptySquare.new([0,7])],
      [Pawn.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(2, [1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2, [1, 7])],
      [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), King.new(2, [2,2]), EmptySquare.new([2,3]), Pawn.new(1, [2,4]), EmptySquare.new([2, 5]), EmptySquare.new([2,6]), Knight.new(2, [2,7])],
      [Pawn.new(1, [3,0]), EmptySquare.new([3, 1]), Pawn.new(1, [3, 2]), EmptySquare.new([3,3]), EmptySquare.new([3,4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), EmptySquare.new([3,7])],
      [EmptySquare.new([4, 0]), EmptySquare.new([4, 1]), Queen.new(1, [4, 2]), EmptySquare.new([4,3]), Knight.new(1, [4,4]), EmptySquare.new([4,5]), EmptySquare.new([4,6]), EmptySquare.new([4,7])],
      [EmptySquare.new([5, 0]), Pawn.new(1, [5,1]), EmptySquare.new([5,2]), Pawn.new(2, [5,3]), EmptySquare.new([5,4]), Bishop.new(1, [5,5]), EmptySquare.new([5,6]), EmptySquare.new([5,7])],
      Array.new(8) { |c| EmptySquare.new([6, c])},
      Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c])}
  ]}

  subject(:board) { Board.new(pawn_can_capture_f7) }

    it 'returns true' do
      start_row = 2
      start_col = 4
      move = 'exf7'
      board.assign_piece_type(move)
      board.assign_target_variables(move, :white)
      starting_piece = board.squares[2][4]
      target_piece = board.squares[1][5]
      result = board.pawn_attack_available?(starting_piece, :white, target_piece)
      expect(result).to be(true)
    end
  end

  context 'when move is a valid en_passant attack' do

    let(:en_passant_move_allowed) {[

      [EmptySquare.new([0,0]), Knight.new(2, [0,1]), Bishop.new(2, [0, 2]), EmptySquare.new([0, 3]), EmptySquare.new([0,4]), EmptySquare.new([0,5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
      [Rook.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(1, [1, 2]), EmptySquare.new([1,3]), King.new(2, [1, 4]), EmptySquare.new([1, 5]), Pawn.new(1, [1,6]), Knight.new(1, [1,7])],
      [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), Pawn.new(1, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2,4]), EmptySquare.new([2,5]), EmptySquare.new([2,6]), Rook.new(1, [2,7])],
      [Pawn.new(2, [3, 0]), Knight.new(1, [3, 1]), EmptySquare.new([3,2]), Pawn.new(2, [3,3]), Pawn.new(1, [3, 4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), Queen.new(1, [3, 7])],
      Array.new(8) { |c| c == 5 ? Bishop.new(1, [4, 5]) : EmptySquare.new([4, c]) },
      Array.new(8) { |c| EmptySquare.new([5, c])},
      Array.new(8) { |c| EmptySquare.new(6, c) },
      Array.new(9) { |c| c == 4 ? King.new(1, [7, 4]) : EmptySquare.new([7, c])}

    ]}

    subject(:board) { Board.new(en_passant_move_allowed) }
    
    it 'calls #manage_en_passant_attack' do
      start_row = 3
      start_col = 4
      move = 'exd6'
      board.assign_piece_type(move)
      board.assign_target_variables(move, :white)
      starting_piece = board.squares[start_row][start_col]
      empty_square_en_passant_target = board.squares[2][3]
      target_square = empty_square_en_passant_target
      expect(board).to receive(:manage_en_passant_attack).with(starting_piece, :white, target_square)
      board.pawn_attack_available?(starting_piece, :white, target_square)
    end

    before do
      move = 'exd6'
      board.assign_piece_type(move)
      board.assign_target_variables(move, :white)
    end

    it 'returns true' do
      start_row = 3
      start_col = 4
      starting_piece = board.squares[start_row][start_col]
      empty_square_en_passant_target = board.squares[2][3]
      allow(board).to receive(:en_passant_conditions_met?).and_return true
      target_square = empty_square_en_passant_target
      result = board.pawn_attack_available?(starting_piece, :white, target_square)
      expect(result).to be(true)
    end

  end
end

describe '#non_pawn_attack_available?' do
  context 'when the attacker is a knight' do
    let(:knight_attack_possible) {[

      [EmptySquare.new([0,0]), Knight.new(2, [0,1]), Bishop.new(2, [0, 2]), EmptySquare.new([0, 3]), EmptySquare.new([0,4]), EmptySquare.new([0,5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
      [Rook.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(1, [1, 2]), EmptySquare.new([1,3]), King.new(2, [1, 4]), EmptySquare.new([1, 5]), Pawn.new(1, [1,6]), Knight.new(1, [1,7])],
      [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), Pawn.new(1, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2,4]), EmptySquare.new([2,5]), EmptySquare.new([2,6]), Rook.new(1, [2,7])],
      [Pawn.new(2, [3, 0]), Knight.new(1, [3, 1]), EmptySquare.new([3,2]), Pawn.new(2, [3,3]), Pawn.new(1, [3, 4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), Queen.new(1, [3, 7])],
      Array.new(8) { |c| c == 5 ? Bishop.new(1, [4, 5]) : EmptySquare.new([4, c]) },
      Array.new(8) { |c| EmptySquare.new([5, c])},
      Array.new(8) { |c| EmptySquare.new(6, c) },
      Array.new(9) { |c| c == 4 ? King.new(1, [7, 4]) : EmptySquare.new([7, c])}

    ]}

    subject(:board) { Board.new(knight_attack_possible) }


    context 'target square is the opposite color' do

      before do
        move = 'Nxa7'
        board.assign_piece_type(move)
        board.assign_target_variables(move, :white)
      end

      it 'returns true' do
        start_row = 3
        start_col = 1
        starting_piece = board.squares[3][1]
        target = board.squares[1][0]
        result = board.non_pawn_attack_available?(start_row, start_col, :white, starting_piece, target)
        expect(result).to be(true)
      end

    end

    context 'target square is an empty square' do

      before do 
        move = 'Nxc3'
        board.assign_piece_type(move)
        board.assign_target_variables(move, :white)
      end

      it 'returns false' do
        start_row = 3
        start_col = 1
        starting_piece = board.squares[3][1]
        target = board.squares[5][2]
        result = board.non_pawn_attack_available?(start_row, start_col, :white, starting_piece, target)
        expect(result).to be(false)
      end
    end
  end

  context 'when a piece other than a knight attacks horizontally or vertically' do

    let(:queen_attacks) {[
        [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]), Queen.new(2, [0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
        Array.new(8) { |c| Pawn.new(2, [1, c]) },
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| Pawn.new(1, [6, c]) },
        [Rook.new(1, [7, 0]), Queen.new(2, [7,1]), EmptySquare.new([7,2]), Rook.new(1, [7,3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
    ]}

    subject(:board) { Board.new(queen_attacks) }

    before do
      move = 'Qxd1'
      board.assign_piece_type(move)
      board.assign_target_variables(move, :black)
    end

    it 'returns true if path is clear' do
      start_row = 7
      start_col = 1
      starting_piece = board.squares[start_row][start_col]
      target = board.squares[7][3]
      result = board.non_pawn_attack_available?(start_row, start_col, :black, starting_piece, target)
      expect(result).to be(true)
    end
  end

  context 'when a piece other than a knight attacks diagonally' do

    let(:queen_attacks) {[
      [Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]), Queen.new(2, [0, 3]), King.new(2, [0, 4]), Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
      Array.new(8) { |c| Pawn.new(2, [1, c]) },
      Array.new(8) { |c| EmptySquare.new([2, c]) },
      Array.new(8) { |c| EmptySquare.new([3, c]) },
      Array.new(8) { |c| EmptySquare.new([4, c]) },
      Array.new(8) { |c| EmptySquare.new([5, c]) },
      Array.new(8) { |c| Pawn.new(1, [6, c]) },
      [Rook.new(1, [7, 0]), Queen.new(2, [7,1]), EmptySquare.new([7,2]), Rook.new(1, [7,3]), King.new(1, [7, 4]), Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7]) ]
  ]}

    subject(:board) { Board.new(queen_attacks) }

    before do
      move = 'Qxc2'
      board.assign_piece_type(move)
      board.assign_target_variables(move, :black)
    end

    it 'returns true if path is clear' do
      start_row = 7
      start_col = 1
      starting_piece = board.squares[start_row][start_col]
      target = board.squares[6][2]
      result = board.non_pawn_attack_available?(start_row, start_col, :black, starting_piece, target)
      expect(result).to be(true)
    end
  end
end