# frozen_string_literal: true

class Board
  include Display
  include MoveValidator
  include InputValidator
  include SetupBoardVariables
  include MoveDisambiguator
  attr_reader :start_row, :start_column, :piece, :piece_type, :piece_found

  def initialize(squares = make_initial_board)
    @squares = squares
    @piece_found = false
    @attack_move = false
    @captured_by_white = []
    @captured_by_black = []
  end

  def make_initial_board
    @squares = [
      black_row,
      Array.new(8) { |c| Pawn.new(2, [1, c]) },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { |c| Pawn.new(1, [6, c]) },
      white_row
    ]
  end

  def black_row
    [
      Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]),
      Queen.new(2, [0, 3]), King.new(2, [0, 4]),
      Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7])
    ]
  end

  def white_row
    [
      Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]),
      Queen.new(1, [7, 3]), King.new(1, [7, 4]),
      Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7])
    ]
  end

  def white_pieces(white_pieces = [])
    @squares.each do |row|
      row.each do |square|
        unless square == ' '
          # @captured_by_white << square if square.captured
          white_pieces << square if square.symbolic_color == :white
        end
      end
    end
    white_pieces
  end

  def black_pieces(black_pieces = [])
    @squares.each do |row|
      row.each do |square|
        unless square == ' '
          # @captured_by_black << square if square.captured
          black_pieces << square if square.symbolic_color == :black
        end
      end
    end
    black_pieces
  end

  def push_captured_pieces
    black_pieces.each { |piece| @captured_by_white << piece if piece.captured }
    white_pieces.each { |piece| @captured_by_black << piece if piece.captured }
  end

  def find_piece(move, player_color, piece_type)
    @piece_found = false
    player_color == :white ? find_white_piece(move, piece_type) : find_black_piece(move, piece_type)
  end

  def find_white_piece(move, piece_type)
    pieces = white_pieces_that_go_to_dest(move).select { |piece| piece.is_a?(piece_type) }
    valid_pawn_attack?(move) ? find_attack_pawn(pieces, move) : count_pieces(pieces, piece_type)
  end

  def find_black_piece(move, piece_type)
    pieces = black_pieces_that_go_to_dest(move).select { |piece| piece.is_a?(piece_type) }
    valid_pawn_attack?(move) ? find_attack_pawn(pieces, move) : count_pieces(pieces, piece_type)
  end

  # prevents unnecessary disambiguation since all pawn attacks indicate starting column
  # and are therefore not ambiguous moves
  def find_attack_pawn(pieces, move)
    attacking_pawn = pieces.select do |p|
      # attacking pawn is the one residing in specified column (the first character entered)
      p.is_a?(Pawn) && p.location[1] == translate_letter_to_index(move[0])
    end[0]
    assign_start_location(attacking_pawn) if attacking_pawn
    @piece_found = true
    attacking_pawn
  end

  def white_pieces_that_go_to_dest(move)
    white_pieces.select do |piece|
      valid_move?(move, piece.location[0], piece.location[1], :white, piece)
    end
  end

  def black_pieces_that_go_to_dest(move)
    black_pieces.select do |piece|
      valid_move?(move, piece.location[0], piece.location[1], :black, piece)
    end
  end

  def update_board
    push_captured_pieces
    @squares[@dest_row][@dest_column] = @squares[@start_row][@start_column]
    @squares[@start_row][@dest_column]  = ' ' if @start_column == @dest_column
    @squares[@start_row][@start_column] = ' ' if @start_column != @dest_column
    @piece.update_num_moves if @piece.is_a?(Pawn)
    @piece.update_location(@dest_row, @dest_column)
    display
  end
end
