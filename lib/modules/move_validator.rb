# frozen_string_literal: true

# examines Boards for obstacles in movement path. determines if attacks are allowed
module MoveValidator
  def valid_move?(start_row, start_column, player_color, piece)
    return false if piece.nil?

    if @attack_move
      attack_rules_followed?(start_row, start_column, player_color, piece)
    elsif @castle_move
      castle_rules_followed?(player_color)
    else
      regular_move_rules_followed?(start_row, start_column, piece)
    end
  end

  def attack_rules_followed?(start_row, start_column, player_color, piece, target = @target)
    if piece.is_a?(Pawn)
      return true if piece.en_passant && en_passant_conditions_met?

      piece.toggle_attack_mode(@squares, start_row, start_column, target.location[0], target.location[1])
    end
    attack_available?(start_row, start_column, player_color, piece, target) &&
      piece.allowed_move?(target.location[0], target.location[1])
  end

  def regular_move_rules_followed?(start_row, start_column, piece, target = @target)
    unless @checking_for_check
      if piece.is_a?(Pawn)
        piece.toggle_attack_mode(@squares, start_row, start_column, target.location[0], target.location[1])
      end
    end
    available_location?(start_row, start_column, piece, target) &&
      piece.allowed_move?(target.location[0], target.location[1])
  end

  def available_location?(start_row, start_column, piece, target = @target)
    piece.update_double_step_move(start_row, target.location[0]) if piece.is_a?(Pawn)
    if piece.is_a?(Knight)
      target.is_a?(EmptySquare)
    elsif horizontal_vertical_move?(start_row, start_column, target)
      horizontal_vertical_unobstructed?(start_row, start_column, target)
    else
      diagonal_has_space_for_move?(start_row, start_column, target)
    end
  end

  def attack_available?(start_row, start_column, player_color, piece, target)
    if piece.is_a?(Pawn)
      pawn_attack_available?(piece, player_color, target)
    else
      non_pawn_attack_available?(start_row, start_column, player_color, piece, target)
    end
  end

  def pawn_attack_available?(piece, player_color, target)
    if piece.en_passant
      manage_en_passant_attack(piece, player_color, target)
    else
      piece.attack_mode && target.symbolic_color != player_color
    end
  end

  def non_pawn_attack_available?(start_row, start_column, player_color, piece, target)
    # can't attack an empty square unless you're a pawn making an en_passant attack
    return false if @target.is_a?(EmptySquare)

    if piece.is_a?(Knight)
      target.symbolic_color != player_color
    elsif horizontal_vertical_move?(start_row, start_column, target)
      path_to_horiz_vert_attack_clear?(start_row, start_column, player_color, target)
    else
      path_to_diagonal_attack_clear?(start_row, start_column, player_color, target)
    end
  end

  def horizontal_vertical_move?(start_row, start_column, target)
    start_row == target.location[0] || start_column == target.location[1]
  end

  def horizontal_vertical_unobstructed?(start_row, start_column, target)
    target.is_a?(EmptySquare) &&
      column_has_space_for_move?(start_row, start_column, target) &&
      row_has_space_for_move?(start_row, start_column, target)
  end

  def path_to_horiz_vert_attack_clear?(start_row, start_column, player_color, target)
    target.symbolic_color != player_color &&
      column_has_space_for_move?(start_row, start_column, target) &&
      row_has_space_for_move?(start_row, start_column, target)
  end

  def path_to_diagonal_attack_clear?(start_row, start_column, player_color, target)
    if target.is_a?(EmptySquare)
      diagonal_has_space_for_move?(start_row, start_column, target)
    else
      target.symbolic_color != player_color &&
        diagonal_has_space_for_move?(start_row, start_column, target)
    end
  end

  # vertical movement
  def column_has_space_for_move?(start_row, _start_column, target)
    target_row = target.location[0]
    if start_row < target_row
      return vertical_path_clear?(start_row + 1, target_row - 1, target) if @attack_move

      vertical_path_clear?(start_row + 1, target_row, target)
    else
      return vertical_path_clear?(target_row + 1, start_row - 1, target) if @attack_move

      vertical_path_clear?(target_row, start_row - 1, target)
    end
  end

  def vertical_path_clear?(starting_place, destination, target)
    starting_place.upto(destination) do |r|
      current_square = @squares[r][target.location[1]]
      return false unless current_square.is_a?(EmptySquare) ||
                          current_square_defending_king?(destination, current_square)
    end
    true
  end

  # horizontal movement
  def row_has_space_for_move?(start_row, start_column, target)
    target_column = target.location[1]
    if start_column < target_column
      return horizontal_path_clear?(start_row, start_column + 1, target_column - 1) if @attack_move

      horizontal_path_clear?(start_row, start_column + 1, target_column)
    else
      return horizontal_path_clear?(start_row, target_column + 1, start_column - 1) if @attack_move

      horizontal_path_clear?(start_row, target_column, start_column - 1)
    end
  end

  def horizontal_path_clear?(start_row, starting_place, destination)
    starting_place.upto(destination) do |c|
      current_square = @squares[start_row][c]
      return false unless current_square.is_a?(EmptySquare) ||
                          current_square_defending_king?(destination, current_square)
    end
    true
  end

  def diagonal_has_space_for_move?(start_row, start_column, target)
    move_distance = (target.location[1] - start_column).abs
    # pieces at bottom have a larger start_row value d/t array index
    objects_in_path = if start_row > target.location[0]
                        ne_nw_diagonal_objects(start_row, start_column, move_distance, target)
                      else
                        se_sw_diagonal_objects(start_row, start_column, move_distance, target)
                      end
    diagonal_path_clear?(objects_in_path, target)
  end

  def diagonal_path_clear?(objects_in_path, target)
    return false unless objects_in_path

    # if any pieces in path are NOT EmptySquares or the defending king (when @checking_for_check),
    # then the path is NOT clear
    objects_in_path.each do |s|
      return false unless s.is_a?(EmptySquare) || current_square_defending_king?(target.location[1], s)
    end
    true
  end

  # prevents defending king from being in the way of a determination of check,
  # e.g. Queen to the right, potential move to the left
  # => he is in the way and it won't register as the move putting himself in check
  def current_square_defending_king?(_destination, current_square)
    return false unless @checking_for_check

    current_square.is_a?(King) &&
      # ensure it's not the attacker's king, @target will always be enemy king when @checking_for_check
      current_square.symbolic_color == @target.symbolic_color
  end

  def ne_nw_diagonal_objects(_start_row, start_column, move_distance, target, diagonal = [])
    move_distance.times do |shift|
      push_north_diagonal(start_column, shift, diagonal, target) if @squares[target.location[0] + shift]
    end
    @attack_move ? diagonal[1..-1] : diagonal
  end

  def se_sw_diagonal_objects(_start_row, start_column, move_distance, target, diagonal = [])
    move_distance.times do |shift|
      push_south_diagonal(start_column, shift, diagonal, target) if @squares[target.location[0] - shift]
    end
    @attack_move ? diagonal.reverse[0..-2] : diagonal
  end

  def push_north_diagonal(start_column, shift, diagonal, target)
    diagonal << if target.location[1] > start_column # (ne)
                  # start at destination location and work backwards towards start piece
                  @squares[target.location[0] + shift][target.location[1] - shift]
                else # (nw)
                  @squares[target.location[0] + shift][target.location[1] + shift]
                end
  end

  def push_south_diagonal(start_column, shift, diagonal, target)
    diagonal << if target.location[1] > start_column # (se)
                  @squares[target.location[0] - shift][target.location[1] - shift]
                else # (sw)
                  @squares[target.location[0] - shift][target.location[1] + shift]
                end
  end
end
