# frozen_string_literal: true

module MoveValidator
  def valid_move?(start_row, start_column, player_color, piece)
    return false if piece.nil?

    if @attack_move
      attack_rules_followed?(start_row, start_column, player_color, piece)
    elsif @castle_move
      castle_rules_followed?(player_color)
    else
      regular_move_rules_followed?(start_row, start_column, player_color, piece)
    end
  end

  def attack_rules_followed?(start_row, start_column, player_color, piece, target = @target)
    return true if piece.is_a?(Pawn) && piece.en_passant && en_passant_conditions_met?

    if piece.is_a?(Pawn)
      piece.toggle_attack_mode(@squares, start_row, start_column, target.location[0], target.location[1])
    end
    attack_available?(start_row, start_column, player_color, piece, target) &&
      piece.allowed_move?(target.location[0], target.location[1])
  end

  def regular_move_rules_followed?(start_row, start_column, _player_color, piece, target = @target)
    piece.toggle_attack_mode(@squares, start_row, start_column, target.location[0], target.location[1]) if piece.is_a?(Pawn)
    available_location?(start_row, start_column, piece) &&
      piece.allowed_move?(target.location[0], target.location[1])
  end

  def available_location?(start_row, start_column, piece, target = @target)
    piece.update_double_step_move(start_row, target.location[0]) if piece.is_a?(Pawn)
    if piece.is_a?(Knight)
      target.is_a?(EmptySquare)
    elsif horizontal_vertical_move?(start_row, start_column, target)
      horizontal_vertical_unobstructed?(start_row, start_column, target)
    else
      diagonal_path_unobstructed?(start_row, start_column, target)
    end
  end

  def attack_available?(start_row, start_column, player_color, piece, target)
    if piece.is_a?(Pawn)
      manage_pawn_attack(piece, player_color, target)
    else
      manage_non_pawn_attacks(start_row, start_column, player_color, piece, target)
    end
  end

  def manage_non_pawn_attacks(start_row, start_column, player_color, piece, target)
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

  def manage_pawn_attack(piece, player_color, target)
    if piece.en_passant
      manage_en_passant_attack(piece, player_color, target)
    else
      piece.attack_mode && target.symbolic_color != player_color
    end
  end

  def manage_en_passant_attack(piece, player_color, target)
    assign_en_passant_target(player_color, target)
    # force attacking pawn to be @found_piece
    @found_piece = @squares[piece.location[0]][piece.location[1]]
    en_passant_conditions_met?
  end

  def assign_en_passant_target(player_color, target)
    return unless target.is_a?(EmptySquare)

    @target = if player_color == :white
                @squares[target.location[0] + 1][target.location[1]]
              else
                @squares[target.location[0] - 1][target.location[1]]
              end
  end

  def en_passant_conditions_met?
    @found_piece.is_a?(Pawn) && @target.is_a?(Pawn) &&
      @target.just_moved_two && @target == @active_piece
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
      diagonal_path_unobstructed?(start_row, start_column, target)
    else
      target.symbolic_color != player_color &&
        diagonal_path_unobstructed?(start_row, start_column, target)
    end
  end

  def column_has_space_for_move?(start_row, _start_column, target)
    if start_row < target.location[0]
      return check_space_between_rows(start_row + 1, target.location[0] - 1, target) if @attack_move

      check_space_between_rows(start_row + 1, target.location[0], target)
    else
      return check_space_between_rows(target.location[0] + 1, start_row - 1, target) if @attack_move

      check_space_between_rows(target.location[0], start_row - 1, target)
    end
  end

  def check_space_between_rows(starting_place, destination, target)
    starting_place.upto(destination) do |r|
      return false unless @squares[r][target.location[1]].is_a?(EmptySquare)
    end
  end

  def row_has_space_for_move?(start_row, start_column, target)
    if start_column < target.location[1]
      return check_space_between_columns(start_row, start_column + 1, target.location[1] - 1) if @attack_move

      check_space_between_columns(start_row, start_column + 1, target.location[1])
    else
      return check_space_between_columns(start_row, target.location[1] + 1, start_column - 1) if @attack_move

      check_space_between_columns(start_row, target.location[1], start_column - 1)
    end
  end

  def check_space_between_columns(start_row, starting_place, destination)
    starting_place.upto(destination) do |c|
      return false unless @squares[start_row][c].is_a?(EmptySquare)
    end
  end

  def diagonal_path_unobstructed?(start_row, start_column, target)
    move_distance = (target.location[1] - start_column).abs
    # pieces at bottom have a larger start_row value d/t array index
    objects_in_path = if start_row > target.location[0]
                        ne_nw_diagonal_objects(start_row, start_column, move_distance, target)
                      else
                        se_sw_diagonal_objects(start_row, start_column, move_distance, target)
                      end
    objects_in_path.any? { |s| !s.is_a?(EmptySquare) } ? false : true
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
