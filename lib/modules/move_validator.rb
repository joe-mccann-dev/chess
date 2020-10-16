# frozen_string_literal: true

module MoveValidator
  def valid_move?(move, start_row, start_column, player_color, piece)
    return false if piece.nil?
    
    if @attack_move
      if attack_rules_followed?(start_row, start_column, player_color, piece)
        # prevents an invalid input target from being marked as captured
        @target.mark_as_captured if piece.is_a?(determine_piece_class(assign_prefix(move)))
        true
      end
    else
      puts 'regular'
      regular_move_rules_followed?(start_row, start_column, player_color, piece)
    end
  end

  def attack_rules_followed?(start_row, start_column, player_color, piece)
    # if piece.is_a?(Pawn)
    #   if @found_piece.is_a?(Pawn) && @found_piece.moved_two_squares?(@start_row)
    #     @target = @squares[@dest_row + 1][@dest_column] if player_color == :white
    #     @target = @squares[@dest_row - 1][@dest_column] if player_color == :black
        # piece.toggle_attack_mode(@squares, start_row, start_column, @dest_row, @dest_column)
    #   else
    #     return false if @target == ' '


    #   end
    # # else

    # return false if @target.is_a?(King) || @target == ' '

      attack_available?(start_row, start_column, player_color, piece) &&
        piece.allowed_move?(@dest_row, @dest_column) 
        !@target.is_a?(King) && @target != ' '
    # end
  end

  def regular_move_rules_followed?(start_row, start_column, player_color, piece)
    available_location?(start_row, start_column, piece) &&
      piece.allowed_move?(@dest_row, @dest_column)
  end

  def available_location?(start_row, start_column, piece)
    piece.toggle_attack_mode(@squares, start_row, start_column, @dest_row, @dest_column) if piece.is_a?(Pawn)
    if piece.is_a?(Knight)
      @target == ' '
    elsif horizontal_vertical_move?(start_row, start_column)
      horizontal_vertical_unobstructed?(start_row, start_column)
    else
      diagonal_path_unobstructed?(start_row, start_column)
    end
  end

  def attack_available?(start_row, start_column, player_color, piece) 
    if piece.is_a?(Pawn)
      piece.toggle_attack_mode(@squares, start_row, start_column, @dest_row, @dest_column)
      if piece.en_passant
        # binding.pry
        en_passant?(player_color)
      else
        piece.attack_mode && 
          @target.symbolic_color != player_color
      end
    elsif piece.is_a?(Knight)
      @target.symbolic_color != player_color
    elsif horizontal_vertical_move?(start_row, start_column)
      path_to_horiz_vert_attack_clear?(start_row, start_column, player_color)
    else
      path_to_diagonal_attack_clear?(start_row, start_column, player_color)
    end
  end

  def en_passant?(player_color)
    @target = @squares[@dest_row + 1][@dest_column] if player_color == :white
    @target = @squares[@dest_row - 1][@dest_column] if player_color == :black
    @found_piece.is_a?(Pawn) && @target.is_a?(Pawn)
  end

  def horizontal_vertical_move?(start_row, start_column)
    start_row == @dest_row || start_column == @dest_column
  end

  def horizontal_vertical_unobstructed?(start_row, start_column)
    @target == ' ' &&
      column_has_space_for_move?(start_row, start_column) &&
      row_has_space_for_move?(start_row, start_column)
  end

  def path_to_horiz_vert_attack_clear?(start_row, start_column, player_color)
    @target.symbolic_color != player_color &&
      column_has_space_for_move?(start_row, start_column) &&
      row_has_space_for_move?(start_row, start_column)
  end

  def path_to_diagonal_attack_clear?(start_row, start_column, player_color)
    @target.symbolic_color != player_color &&
      diagonal_path_unobstructed?(start_row, start_column)
  end

  def column_has_space_for_move?(start_row, start_column)
    if start_row < @dest_row
      return check_space_between_rows(start_row + 1, @dest_row - 1) if @attack_move

      check_space_between_rows(start_row + 1, @dest_row)
    else
      return check_space_between_rows(@dest_row + 1, start_row - 1) if @attack_move

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
      return check_space_between_columns(start_row, start_column + 1, @dest_column - 1) if @attack_move

      check_space_between_columns(start_row, start_column + 1, @dest_column)
    else
      return check_space_between_columns(start_row, @dest_column + 1, start_column - 1) if @attack_move

      check_space_between_columns(start_row, @dest_column, start_column - 1)
    end
  end

  def check_space_between_columns(start_row, starting_place, destination)
    starting_place.upto(destination) do |c|  
      return false if @squares[start_row][c] != ' '
    end
  end

  def diagonal_path_unobstructed?(start_row, start_column)
    move_distance = (@dest_column - start_column).abs
    # pieces at bottom have a larger start_row value d/t array index
    if start_row > @dest_row
      objects_in_path = ne_nw_diagonal_objects(start_row, start_column, move_distance)
    else
      objects_in_path = se_sw_diagonal_objects(start_row, start_column, move_distance)
    end
    objects_in_path.any? { |s| s != ' ' } ? false : true
  end

  def ne_nw_diagonal_objects(start_row, start_column, move_distance, diagonal = [])
    move_distance.times do |n|
      push_north_diagonal(start_column, n, diagonal) if @squares[@dest_row + n]
    end
    @attack_move ? diagonal[1..-1] : diagonal
  end

  def se_sw_diagonal_objects(start_row, start_column, move_distance, diagonal = [])
    move_distance.times do |n|
      push_south_diagonal(start_column, n, diagonal) if @squares[@dest_row - n]
    end
    @attack_move ? diagonal.reverse[0..-2] : diagonal
  end

  def push_north_diagonal(start_column, n, diagonal)
    if @dest_column > start_column # (ne)
      # start at destination location and work backwards towards start piece
      diagonal << @squares[@dest_row + n][@dest_column - n]
    else # (nw)
      diagonal << @squares[@dest_row + n][@dest_column + n]
    end
  end

  def push_south_diagonal(start_column, n, diagonal)
    if @dest_column > start_column # (se)
      diagonal << @squares[@dest_row - n][@dest_column - n]
    else # (sw)
      diagonal << @squares[@dest_row - n][@dest_column + n]
    end
  end
end
