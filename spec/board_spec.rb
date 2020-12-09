require 'colorize'
require_relative '../lib/modules/display'
require_relative '../lib/modules/setup_board_variables'
require_relative '../lib/modules/adjacency_list_generator'
require_relative '../lib/modules/input_validator'
require_relative '../lib/modules/move_validator'
require_relative '../lib/modules/move_disambiguator'
require_relative '../lib/modules/castle_manager'
require_relative '../lib/modules/checkmate_manager'
require_relative '../lib/modules/pawn_promotion.rb'
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

describe Board do
  describe '#initialize' do
    context 'when no board state is give' do

      subject(:board) { described_class.new }

      it 'makes the initial board' do
        initial_board = board.make_initial_board
        expect(board.squares).to eq(initial_board)
      end
    end
  end

  describe '#duplicate_board' do

    context 'when current board state is passed into a new Board object' do

      subject(:current_board) { described_class.new }
      subject(:new_board) { described_class.new(current_board.squares) }

      it 'populates a new board with new piece objects' do
        expect(new_board).not_to eq(current_board)
      end

      it 'contains the same amount of objects as the original' do
        current_board_count = 0
        new_board_count = 0
        current_board.squares.each { |r| r.each { |s| current_board_count += 1 } }
        new_board.squares.each { |r| r.each { |s| new_board_count += 1} }
        expect(current_board_count).to eq(new_board_count)
      end

      it 'has the same amount of rows as the original' do
        expect(current_board.squares.length).to eq(new_board.squares.length)
      end
    end
  end

  describe '#find_piece' do
    context 'when move is a castle move' do

      subject(:board) { described_class.new }

      it 'returns king of current player color' do
        move = '0-0'
        player_color = :white
        piece_type = Knight
        found_piece = board.find_piece(move, player_color, King)
        white_king = board.squares[7][4]
        expect(found_piece).to eq(white_king)
      end
    end

    context 'when move is not a castle move' do

      subject(:board) { described_class.new }

      it 'finds the relevant white or black piece' do
        move = 'Nc3'
        player_color = :white
        piece_type = Knight
        white_knight = board.squares[7][1]
        # no "allow" necessary for castle move spec because piece is essentially found
        allow(board).to receive(:white_pieces_that_go_to_dest).and_return([white_knight])
        expect(board.find_piece(move, player_color, piece_type)).to eq(white_knight)
      end
    end
  end

  describe '#find_white_piece' do
    context 'when move is a pawn attack' do

      subject(:board) { described_class.new }

      it 'finds which pawn is attacking' do
        move = 'axb3'
        piece_type = Pawn
        attacking_pawn = board.squares[6][0]
        allow(board).to receive(:white_pieces_that_go_to_dest).and_return([attacking_pawn])
        expect(board.find_white_piece(move, piece_type)).to eq(attacking_pawn)
      end
    end

    context 'when move is not a pawn attack' do

      subject(:board) { described_class.new }

      it 'returns the found piece' do
        move = 'Nf3'
        piece_type = Knight
        white_knight = board.squares[7][6]
        allow(board).to receive(:white_pieces_that_go_to_dest).and_return([white_knight])
        expect(board.find_white_piece(move, piece_type)).to eq(white_knight)
      end
    end
  end

  describe '#update_board' do
    context 'after piece type and target variables are assigned' do
      subject(:board) { described_class.new }
      move = 'e4'
      player_color = :white

      before do
        board.assign_piece_type(move)
        # necessary to assign @dest_row and @dest_col to the relevant squares
        board.assign_target_variables(move, player_color)
      end

      it 'updates an available square to be the found piece' do
        result = board.update_board(move, player_color)
        new_pawn_location = board.squares[4][4]
        expect(result).to eq(new_pawn_location)
      end
    end
  end
end
