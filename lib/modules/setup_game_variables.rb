# frozen_string_literal: true

module SetupGameVariables
  def set_piece_type(move)
    @prefix = set_prefix(move)
    @piece_type = determine_piece_class(@prefix)
  end

  def set_prefix(move)
    @prefix = move.length == 2 ? '' : move[0].upcase
  end

  def determine_piece_class(prefix)
    piece_objects = [Pawn, Rook, Knight, Bishop, Queen, King]
    prefixes = ['', 'R', 'N', 'B', 'Q', 'K']
    prefixes.each_with_index do |p, index|
      return piece_objects[index] if p == prefix
    end
  end

  def set_index_variables(move, player_color)
    @dest_row = find_dest_row(move)
    @dest_column = determine_dest_column(move)
    @piece = @board.find_piece(@dest_row, @dest_column, player_color, @piece_type)
    @start_row = @piece.location[0] if @piece
    @start_column = @piece.location[1] if @piece
  end

  def find_dest_row(move)
    chess_rows = [8, 7, 6, 5, 4, 3, 2, 1]
    move.length == 2 ? chess_rows.index(move[1].to_i) : chess_rows.index(move[2].to_i)
  end

  def determine_dest_column(move)
    if move.length == 2
      find_dest_column(move[0].downcase)
    else
      find_dest_column(move[1].downcase)
    end
  end

  def find_dest_column(letter)
    ('a'..'h').select.each_with_index { |_x, index| index }.index(letter)
  end
end