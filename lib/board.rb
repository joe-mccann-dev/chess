# frozen_string_literal: true

class Board
  include Display

  def initialize(squares = make_initial_board)
    @squares = squares
  end

  def make_initial_board
    @squares = [
      black_row,
      Array.new(8) { |i| Pawn.new(2, [1, i]) },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { |i| Pawn.new(1, [6, i]) },
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
          black_pieces << square if square.symbolic_color == :black
        end
      end
    end
    black_pieces
  end

  def update_board(start_row, dest_row, column, piece)
    @squares[dest_row][column] = @squares[start_row][column]
    @squares[start_row][column] = ' '
    piece.update_num_moves if piece.is_a?(Pawn)
    piece.update_location(dest_row, column)
  end

  # will return zero if piece is not in column argument
  # 
  def find_start_row(column, player_color, piece_type)
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

  def find_dest_row(move)
    chess_rows = [8, 7, 6, 5, 4, 3, 2, 1]
    move.length == 2 ? chess_rows.index(move[1].to_i) : chess_rows.index(move[2].to_i)
  end

  def find_start_column(piece)
    puts "start_column: #{piece.location[1]}"
    piece.location[1]
  end

  def find_dest_column(letter)
    ('a'..'h').select.each_with_index { |_x, index| index }.index(letter)
  end

  def valid_move?(start_row, dest_row, column, player_color, piece)
    puts "starting_row: #{start_row}"
    column.between?(0, 7) && dest_row.between?(0, 7) &&
      available_location?(start_row, dest_row, column) &&
      piece.allowed_move?(start_row, dest_row, player_color)
  end

  def available_location?(start_row, dest_row, column)
    @squares[dest_row][column] == ' ' && 
      column_has_space_for_move?(start_row, dest_row, column)
  end

  def column_has_space_for_move?(start_row, dest_row, column)
    if start_row < dest_row
      start = start_row + 1
      column_check_helper(start, dest_row, column)
    else
      start = start_row - 1
      column_check_helper(dest_row, start, column)
    end
  end

  def column_check_helper(start, dest_row, column)
    start.upto(dest_row) do |row|
      return false if @squares[row][column] != ' '
    end
    true
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
