# frozen_string_literal: true

module MoveValidator
  def valid_move?(start_row, start_column, player_color, piece)
    available_location?(start_row, start_column, piece) &&
      piece.allowed_move?(@dest_row, @dest_column)
  end

  def available_location?(start_row, start_column, piece)
    return allowed_knight_move?(piece) if piece.is_a?(Knight)
    return diagonal_path_unobstructed?(start_row, start_column) if piece.is_a?(Queen)
    @squares[@dest_row][@dest_column] == ' ' &&
      column_has_space_for_move?(start_row, start_column) &&
      row_has_space_for_move?(start_row, start_column)
  end

  def diagonal_path_unobstructed?(start_row, start_column)
    move_distance = (@dest_column - start_column).abs
    if start_row > @dest_row
      objects_in_path = ne_nw_diagonal_objects(start_row, start_column, move_distance)
    else
      objects_in_path = se_sw_diagonal_objects(start_row, start_column, move_distance)
    end
    puts "objects_in_path: #{objects_in_path}"
    if objects_in_path.any? { |s| s != ' ' }
      return false
    end
    true
  end

  def ne_nw_diagonal_objects(start_row, start_column, move_distance)
    diagonal = []
    (move_distance).times do |n|
      if @dest_column > start_column
        puts 'start_row > @dest_row | @dest_column > start_column (ne)'
        diagonal << @squares[@dest_row + n][@dest_column - n]
      else
        puts 'start_row > @dest_row | @ dest_column < start_column (nw)'
        diagonal << @squares[@dest_row + n][@dest_column + n]
      end
    end
    diagonal
  end

  def se_sw_diagonal_objects(start_row, start_column, move_distance)
    diagonal = []
    (move_distance).times do |n|
      if @dest_column > start_column
        puts '@dest_row > start_row | @dest_column > start_column (se)'
        diagonal << @squares[@dest_row - n][@dest_column - n]
      else
        puts '@dest_row > start_row | @dest_column < start_column (sw)'
        diagonal << @squares[@dest_row - n][@dest_column + n]
      end
    end
    diagonal
  end

  def allowed_knight_move?(piece)
    @squares[@dest_row][@dest_column] == ' ' &&
      piece.allowed_move?(@dest_row, @dest_column)
  end

  def column_has_space_for_move?(start_row, start_column)
    if start_row < @dest_row
      check_space_between_rows(start_row + 1, @dest_row)
    else
      check_space_between_rows(@dest_row, start_row - 1)
    end
  end

  def check_space_between_rows(starting_place, destination)
    starting_place.upto(destination) do |r|
      return false if @squares[r][@dest_column] != ' '
    end
  end

  def row_has_space_for_move?(start_row, start_column)
    if start_column < @dest_column
      check_space_between_columns(start_row, start_column + 1, @dest_column)
    else
      check_space_between_columns(start_row, @dest_column, start_column - 1)
    end
  end

  def check_space_between_columns(start_row, starting_place, destination)
    starting_place.upto(destination) do |c|  
      return false if @squares[start_row][c] != ' '
    end
  end
end
