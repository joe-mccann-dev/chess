# frozen_string_literal: true

class Board
  include Display
  attr_reader :squares

  def initialize(squares = make_initial_board)
    @squares = squares
  end

  def make_initial_board
    @squares = [
      black_row,
      Array.new(8) { Pawn.new(2) },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { Pawn.new(1) },
      white_row
    ]
  end

  def white_row
    [
      Rook.new(1), Knight.new(1), Bishop.new(1),
      Queen.new(1), King.new(1),
      Bishop.new(1), Knight.new(1), Rook.new(1)
    ]
  end

  def black_row
    [
      Rook.new(2), Knight.new(2), Bishop.new(2),
      Queen.new(2), King.new(2),
      Bishop.new(2), Knight.new(2), Rook.new(2)
    ]
  end

  def update_board(start_row, dest_row, column, piece)
    @squares[dest_row][column] = @squares[start_row][column]
    @squares[start_row][column] = ' '
    piece.update_num_moves if piece.is_a?(Pawn)
  end

  def find_starting_index(column, player_color, piece_type)
    0.upto(7) do |row|
      piece = @squares[row][column]
      if @squares[row][column] != ' ' && @squares[row][column].symbolic_color == player_color
        return row if piece.is_a?(piece_type)
      end
    end
  end

  def assign_piece(column, player_color, piece_type)
    0.upto(7) do |row|
      piece = @squares[row][column]
      if @squares[row][column] != ' ' && @squares[row][column].symbolic_color == player_color
        puts "piece_type: #{piece_type}"
        return piece if piece.is_a?(piece_type)
      end
    end
  end

  def find_destination_index(move)
    chess_rows = [8, 7, 6, 5, 4, 3, 2, 1]
    move.length == 2 ? chess_rows.index(move[1].to_i) : chess_rows.index(move[2].to_i)
  end

  def find_letter_index(letter)
    ('a'..'h').select.each_with_index { |_x, index| index }.index(letter)
  end

  def valid_move?(start_row, dest_row, column, player_color, piece)
    p "starting_row: #{start_row}"
    column.between?(0, 7) && dest_row.between?(0, 7) &&
      available_location?(dest_row, column) &&
      piece.allowed_move?(start_row, dest_row, player_color)
  end

  def available_location?(dest_row, column)
    @squares[dest_row][column] == ' '
  end

  def determine_piece_class(prefix)
    return Pawn   if prefix == ''
    return Rook   if prefix == 'R'
    return Knight if prefix == 'N'
    return Bishop if prefix == 'B'
    return Queen  if prefix == 'Q'
    return King   if prefix == 'K'
  end
end
