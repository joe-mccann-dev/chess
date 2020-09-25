# frozen_string_literal: true

module MoveValidator
  def valid_input?(move)
    return false unless move.length.between?(2, 3)

    if move.length == 2
      valid_pawn_move?(move)
    else
      valid_character_move?(move)
    end
  end

  def valid_pawn_move?(move)
    move[0].downcase.match?(/[a-h]/) &&
      move[1].match?(/[1-8]/)
  end

  def valid_character_move?(move)
    move[0].upcase.match?(/R|N|B|Q|K/) &&
      move[1].downcase.match?(/[a-h]/) &&
      move[2].match?(/[1-8]/)
  end

  def valid_move?(start_row, dest_row, start_column, dest_column, player_color, piece)
    available_location?(start_row, dest_row, start_column, dest_column) &&
      piece.allowed_move?(start_row, dest_row, player_color, start_column, dest_column)
  end

  def available_location?(start_row, dest_row, start_column, dest_column)
    @squares[dest_row][dest_column] == ' ' &&
      column_has_space_for_move?(start_row, dest_row, dest_column) &&
      row_has_space_for_move?(start_row, dest_row, start_column, dest_column)
  end

  def column_has_space_for_move?(start_row, dest_row, dest_column)
    if start_row < dest_row
      check_space_between_rows(start_row + 1, dest_row, dest_column)
    else
      check_space_between_rows(dest_row, start_row - 1, dest_column)
    end
  end

  def check_space_between_rows(starting_place, destination, dest_column)
    starting_place.upto(destination) do |r|
      return false if @squares[r][dest_column] != ' '
    end
  end

  def row_has_space_for_move?(start_row, dest_row, start_column, dest_column)
    if dest_column > start_column
      check_space_between_columns(start_row, dest_row, start_column + 1, dest_column)
    else
      check_space_between_columns(start_row, dest_row, dest_column, start_column - 1)
    end
  end

  def check_space_between_columns(start_row, dest_row, starting_place, destination)
    starting_place.upto(destination) do |c|
      return false if @squares[start_row][c] != ' '
    end
  end
end
