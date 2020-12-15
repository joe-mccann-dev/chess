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

    context 'when black is surrounded and in checkmate by bishop' do

      let(:king_in_check_by_bishop) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), EmptySquare.new([0,4]), Queen.new(2, [0, 5]), Bishop.new(2, [0,6]), EmptySquare.new([0,7])],
        [Pawn.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(2, [1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2, [1, 7])],
        [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), King.new(2, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2, 4]), Knight.new(1, [2,5]), EmptySquare.new([2,6]), Knight.new(2, [2,7])],
        [Pawn.new(1, [3,0]), EmptySquare.new([3, 1]), Pawn.new(1, [3, 2]), EmptySquare.new([3,3]), Pawn.new(1, [3,4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), EmptySquare.new([3,7])],
        [EmptySquare.new([4, 0]), EmptySquare.new([4, 1]), Queen.new(1, [4, 2]), EmptySquare.new([4,3]), EmptySquare.new([4,4]), EmptySquare.new([4,5]), EmptySquare.new([4,6]), EmptySquare.new([4,7])],
        [EmptySquare.new([5, 0]), Pawn.new(1, [5,1]), EmptySquare.new([5,2]), Pawn.new(2, [5,3]), EmptySquare.new([5,4]), Bishop.new(1, [5,5]), EmptySquare.new([5,6]), EmptySquare.new([5,7])],
        Array.new(8) { |c| EmptySquare.new([6, c])},
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c])}
      ]}
      
      subject(:board) { Board.new(king_in_check_by_bishop) }
      subject(:game) { described_class.new(board) }

      it 'returns true' do
        # bishop at f3
        active_piece = board.squares[5][5]
        result = game.checkmate?(attacking_color, board, active_piece)
        expect(result).to be(true)
      end

    end

    context 'when white moves a piece that reveals a check, leading to checkmate' do
    

      let(:king_almost_in_checkmate) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), EmptySquare.new([0,4]), Queen.new(2, [0, 5]), Bishop.new(2, [0,6]), EmptySquare.new([0,7])],
        [Pawn.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(2, [1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2, [1, 7])],
        [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), King.new(2, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2, 4]), EmptySquare.new([2, 5]), EmptySquare.new([2,6]), Knight.new(2, [2,7])],
        [Pawn.new(1, [3,0]), EmptySquare.new([3, 1]), Pawn.new(1, [3, 2]), EmptySquare.new([3,3]), Pawn.new(1, [3,4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), EmptySquare.new([3,7])],
        [EmptySquare.new([4, 0]), EmptySquare.new([4, 1]), Queen.new(1, [4, 2]), EmptySquare.new([4,3]), Knight.new(1, [4,4]), EmptySquare.new([4,5]), EmptySquare.new([4,6]), EmptySquare.new([4,7])],
        [EmptySquare.new([5, 0]), Pawn.new(1, [5,1]), EmptySquare.new([5,2]), Pawn.new(2, [5,3]), EmptySquare.new([5,4]), Bishop.new(1, [5,5]), EmptySquare.new([5,6]), EmptySquare.new([5,7])],
        Array.new(8) { |c| EmptySquare.new([6, c])},
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c])}
      ]}


      subject(:board) { Board.new(king_almost_in_checkmate) }
      subject(:game) { described_class.new(board) }

      it 'returns true' do
        board.assign_piece_type('Nf6')
        board.assign_target_variables('Nf6', :white)
        # empty square at squares[2][5] now becomes the white knight
        # white knight at e4 moves to f6 (squares[2][5]) 
        #resulting in white bishop putting king in check and ultimately checkmate
        board.update_board('Nf6', attacking_color)
        active_piece = board.squares[2][5]
        result = game.checkmate?(attacking_color, board, active_piece)
        expect(result).to be(true)
      end
    end

    context 'when it is almost checkmate, but defender can capture attacker' do
      let(:black_knight_can_capture_attacker) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), King.new(2, [0, 4]), EmptySquare.new([0,5]), Knight.new(2, [0,6]), Rook.new(2, [0,7])],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), EmptySquare.new([1,3]), Queen.new(1, [1,4]), EmptySquare.new([1,5]), EmptySquare.new([1,6]), EmptySquare.new(1, 7)],
        Array.new(8) { |c| c == 6 ? Knight.new(1, [2, 6]) : EmptySquare.new([2, c]) },
        Array.new(8) { |c| EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c]) }
      ]}

      subject(:board) { Board.new(black_knight_can_capture_attacker) }
      subject(:game) { described_class.new(board) }

      it 'returns false' do
        active_piece = board.squares[1][4]
        result = game.checkmate?(attacking_color, board, active_piece)
        expect(result).to be(false)
      end
    end

    context 'when an en_passant move results in checkmate' do

      let(:white_about_to_en_passant_black_into_mate) {[
        [EmptySquare.new([0,0]), Knight.new(2, [0,1]), Bishop.new(2, [0, 2]), EmptySquare.new([0, 3]), EmptySquare.new([0,4]), EmptySquare.new([0,5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7]) ],
        [Rook.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(1, [1, 2]), EmptySquare.new([1,3]), King.new(2, [1, 4]), EmptySquare.new([1, 5]), Pawn.new(1, [1,6]), Knight.new(1, [1,7])],
        [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), Pawn.new(1, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2,4]), EmptySquare.new([2,5]), EmptySquare.new([2,6]), Rook.new(1, [2,7])],
        [Pawn.new(2, [3, 0]), Knight.new(1, [3, 1]), EmptySquare.new([3,2]), Pawn.new(2, [3,3]), Pawn.new(1, [3, 4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), Queen.new(1, [3, 7])],
        Array.new(8) { |c| c == 5 ? Bishop.new(1, [4, 5]) : EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c])},
        Array.new(8) { |c| EmptySquare.new(6, c) },
        Array.new(9) { |c| c == 4 ? King.new(1, [7, 4]) : EmptySquare.new([7, c])}
      ]}

      subject(:board) { Board.new(white_about_to_en_passant_black_into_mate) }
      subject(:game) { described_class.new(board) }

      it 'returns true' do
        board.assign_target_variables('exd6', :white)
        board.instance_variable_set(:@start_row, 3)
        board.instance_variable_set(:@start_column, 4)
        board.instance_variable_set(:@found_piece, board.squares[3][4])
        board.update_board('exd6', attacking_color)
        # en_passant attacker after its location is updated
        active_piece = board.squares[2][3]
        result = game.checkmate?(attacking_color, board, active_piece)
        expect(result).to be(true)
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

  describe '#stalemate?' do

    let(:attacking_color) { :white }

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

      it 'returns true' do
        active_piece = board.squares[2][5]
        result = game.stalemate?(attacking_color, board, active_piece)
        expect(result).to be(true)
      end
    end

    context 'when it is not stalemate' do

      let(:not_in_stalemate) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), King.new(2, [0, 4]), EmptySquare.new([0,5]), EmptySquare.new([0,6]), EmptySquare.new([0,7])],
        [EmptySquare.new([1,0]), EmptySquare.new([1,1]), EmptySquare.new([1,2]), EmptySquare.new([1,3]), EmptySquare.new([1,4]), EmptySquare.new([1,5]), EmptySquare.new([1,6]), Queen.new(1, [1,7])],
        Array.new(8) { |c| EmptySquare.new([2, c]) },
        Array.new(8) { |c| c == 6 ? Queen.new(1, [3,6]) : EmptySquare.new([3, c]) },
        Array.new(8) { |c| EmptySquare.new([4, c]) },
        Array.new(8) { |c| EmptySquare.new([5, c]) },
        Array.new(8) { |c| EmptySquare.new([6, c]) },
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c]) }
      ]}

      subject(:board) { Board.new(not_in_stalemate) }
      subject(:game) { described_class.new(board) }

      it 'returns false' do
        active_piece = board.squares[3][6]
        result = game.stalemate?(attacking_color, board, active_piece)
        expect(result).to be(false)
      end
    end
  end

  describe '#game_over?' do
    let(:attacking_color) { :white }

    context 'when it is not game over' do

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
    

      subject(:board) { described_class.new(black_not_in_checkmate) }
      subject(:game) { described_class.new(board) }

      it 'returns false' do
        result = game.game_over?
        expect(result).to be(false)
      end
    end

    context 'when it is checkmate' do

      let(:board_checkmate) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), EmptySquare.new([0,4]), Queen.new(2, [0, 5]), Bishop.new(2, [0,6]), EmptySquare.new([0,7])],
        [Pawn.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(2, [1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2, [1, 7])],
        [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), King.new(2, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2, 4]), Knight.new(1, [2,5]), EmptySquare.new([2,6]), Knight.new(2, [2,7])],
        [Pawn.new(1, [3,0]), EmptySquare.new([3, 1]), Pawn.new(1, [3, 2]), EmptySquare.new([3,3]), Pawn.new(1, [3,4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), EmptySquare.new([3,7])],
        [EmptySquare.new([4, 0]), EmptySquare.new([4, 1]), Queen.new(1, [4, 2]), EmptySquare.new([4,3]), EmptySquare.new([4,4]), EmptySquare.new([4,5]), EmptySquare.new([4,6]), EmptySquare.new([4,7])],
        [EmptySquare.new([5, 0]), Pawn.new(1, [5,1]), EmptySquare.new([5,2]), Pawn.new(2, [5,3]), EmptySquare.new([5,4]), Bishop.new(1, [5,5]), EmptySquare.new([5,6]), EmptySquare.new([5,7])],
        Array.new(8) { |c| EmptySquare.new([6, c])},
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c])}
      ]}

      subject(:board) { Board.new(board_checkmate) }
      subject(:game) { described_class.new(board) }

      it 'returns true' do
        # bishop that just accomplished checkmate
        found_piece = board.squares[5][5]
        game.determine_check_status(attacking_color, board, found_piece)
        result = game.game_over?
        expect(result).to be(true)
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

      it 'returns true' do
        # most recently moved queen
        found_piece = board.squares[2][5]
        game.determine_check_status(attacking_color, board, found_piece)
        result = game.game_over?
        expect(result).to be(true)
      end
    end

    context 'when a player requests a draw' do
      
      subject(:game) { described_class.new }

      before do
        allow(game).to receive(:puts)
        allow(game).to receive(:gets).and_return('Y')
        allow(game).to receive(:draw_offer_message)
      end

      it 'returns true if the other player accepts' do
        game.request_draw
        result = game.game_over?
        expect(result).to be(true)
      end
    end

    context 'when a player resigns' do
      
      subject(:game) { described_class.new }
      subject(:current_player) { Player.new('bob') }

      before do
        allow(game).to receive(:puts)
      end

      it 'returns true' do
        game.instance_variable_set(:@current_player, current_player)
        game.resign_match
        result = game.game_over?
        expect(result).to be(true)
      end
    end
  end

  describe '#every_king_move_results_in_check?' do

    let(:attacking_color) { :white }

    context 'when every move puts king in check' do

      let(:king_cannot_escape) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), EmptySquare.new([0,4]), Queen.new(2, [0, 5]), Bishop.new(2, [0,6]), EmptySquare.new([0,7])],
        [Pawn.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(2, [1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2, [1, 7])],
        [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), King.new(2, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2, 4]), Knight.new(1, [2,5]), EmptySquare.new([2,6]), Knight.new(2, [2,7])],
        [Pawn.new(1, [3,0]), EmptySquare.new([3, 1]), Pawn.new(1, [3, 2]), EmptySquare.new([3,3]), Pawn.new(1, [3,4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), EmptySquare.new([3,7])],
        [EmptySquare.new([4, 0]), EmptySquare.new([4, 1]), Queen.new(1, [4, 2]), EmptySquare.new([4,3]), EmptySquare.new([4,4]), EmptySquare.new([4,5]), EmptySquare.new([4,6]), EmptySquare.new([4,7])],
        [EmptySquare.new([5, 0]), Pawn.new(1, [5,1]), EmptySquare.new([5,2]), Pawn.new(2, [5,3]), EmptySquare.new([5,4]), Bishop.new(1, [5,5]), EmptySquare.new([5,6]), EmptySquare.new([5,7])],
        Array.new(8) { |c| EmptySquare.new([6, c])},
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c])}
      ]}

      subject(:board) { Board.new(king_cannot_escape) }
      subject(:game) { described_class.new(board) }

      it 'returns true' do
        result = game.every_king_move_results_in_check?(attacking_color, board)
        expect(result).to be(true)
      end
    end

    context 'when king has escape move available' do
      # queen above replaced with empty square
      let(:king_can_escape) {[
        [EmptySquare.new([0,0]), EmptySquare.new([0,1]), EmptySquare.new([0, 2]), EmptySquare.new([0,3]), EmptySquare.new([0,4]), Queen.new(2, [0, 5]), Bishop.new(2, [0,6]), EmptySquare.new([0,7])],
        [Pawn.new(2, [1, 0]), Pawn.new(2, [1, 1]), Pawn.new(2, [1, 2]), EmptySquare.new([1, 3]), Pawn.new(2, [1, 4]), Pawn.new(2, [1, 5]), Pawn.new(2, [1, 6]), Pawn.new(2, [1, 7])],
        [EmptySquare.new([2,0]), EmptySquare.new([2, 1]), King.new(2, [2,2]), EmptySquare.new([2,3]), EmptySquare.new([2, 4]), Knight.new(1, [2,5]), EmptySquare.new([2,6]), Knight.new(2, [2,7])],
        [Pawn.new(1, [3,0]), EmptySquare.new([3, 1]), Pawn.new(1, [3,2]), EmptySquare.new([3,3]), Pawn.new(1, [3,4]), EmptySquare.new([3,5]), EmptySquare.new([3,6]), EmptySquare.new([3,7])],
        [EmptySquare.new([4, 0]), EmptySquare.new([4, 1]), EmptySquare.new([4,2]), EmptySquare.new([4,3]), EmptySquare.new([4,4]), EmptySquare.new([4,5]), EmptySquare.new([4,6]), EmptySquare.new([4,7])],
        [EmptySquare.new([5, 0]), Pawn.new(1, [5,1]), EmptySquare.new([5,2]), Pawn.new(2, [5,3]), EmptySquare.new([5,4]), Bishop.new(1, [5,5]), EmptySquare.new([5,6]), EmptySquare.new([5,7])],
        Array.new(8) { |c| EmptySquare.new([6, c])},
        Array.new(8) { |c| c == 4 ? King.new(1, [7,4]) : EmptySquare.new([7, c])}
      ]}

      subject(:board) { Board.new(king_can_escape) }
      subject(:game) { described_class.new(board) }

      it 'returns false' do
        result = game.every_king_move_results_in_check?(attacking_color, board)
        expect(result).to be(false)
      end
    end
  end
end