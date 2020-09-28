# frozen_string_literal: true

module MoveValidator

  def valid_move?(start_row, dest_row, start_column, dest_column, player_color, piece)
    available_location?(start_row, dest_row, start_column, dest_column) &&
      piece.allowed_move?(start_row, dest_row, player_color, start_column, dest_column)
  end

  def available_location?(start_row, dest_row, start_column, dest_column)
    # if move is diagonal, do a different set of conditionals??
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
      return true if simple_diagonal_movemment?(start_row, dest_row, starting_place, destination)
  
      return false if @squares[start_row][c] != ' '
    end
  end
  
  def simple_diagonal_movemment?(start_row, dest_row, starting_place, destination)
    (dest_row - start_row).abs <= 1 &&
      (starting_place - destination).abs <= 1 &&
      @squares[dest_row][destination] == ' '
  end

end