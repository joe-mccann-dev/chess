# frozen_string_literal: true

module CheckmateManager
  def check?
    white_king.in_check || black_king.in_check
  end

  def white_king
   white_pieces.select { |piece| piece.is_a?(King) }[0]
  end

  def black_king
    black_pieces.select { |piece| piece.is_a?(King) }[0]
  end

  def mark_king_as_in_check?(player_color)
    mark_kings_as_not_in_check
    if player_color == :white
      black_king.mark_as_in_check if white_puts_black_in_check?(player_color)
    else
      white_king.mark_as_in_check if black_puts_white_in_check?(player_color)
    end
  end

  # def checkmate?(player_color)
  #   allowed_moves = if player_color == :white
  #                     white_king.available_squares
  #                   else
  #                     black_king.available_squares
  #                   end
  #                   p allowed_moves
  #   i = 0
  #   moves_that_result_in_check = []
  #   original_allowed_moves = allowed_moves
  #   until allowed_moves.empty?
  #     opposite_color = player_color == :white ? :black : :white
  #     # binding.pry
  #     move = allowed_moves[0]
  #     reassign_relevant_board_variables(opposite_color, move[0], move[1])
  #     if move_puts_self_in_check?(player_color)
  #       moves_that_result_in_check << allowed_moves[i]
  #     end
  #     allowed_moves.shift
  #     i += 1
  #   end
  #   moves_that_result_in_check.any? && moves_that_result_in_check.length == original_allowed_moves.length
  # end

  def mark_kings_as_not_in_check
    white_king.mark_as_not_in_check
    black_king.mark_as_not_in_check
  end

  def move_puts_player_in_check?(player_color)
    reassign_relevant_board_variables(player_color)
    mark_king_as_in_check?(player_color)
  end

  def move_puts_self_in_check?(player_color)
    opposite_color = player_color == :white ? :black : :white
    reassign_relevant_board_variables(opposite_color)
    mark_king_as_in_check?(opposite_color)
  end

  def reassign_relevant_board_variables(player_color)
    if player_color == :white
      @dest_row = black_king.location[0]
      @dest_column = black_king.location[1]
    else
      @dest_row = white_king.location[0]
      @dest_column = white_king.location[1]
    end
    @checking_for_check = true
    @target = @squares[@dest_row][@dest_column]
    @attack_move = true
  end

  def white_puts_black_in_check?(player_color)
    white_pieces.any? do |piece|
      if @en_passant
        if piece.allowed_move?(black_king.location[0], black_king.location[1])
          path_to_horiz_vert_attack_clear?(piece.location[0], piece.location[1], player_color, black_king) ||
            path_to_diagonal_attack_clear?(piece.location[0], piece.location[1], player_color, black_king)
        end
      else
        attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece)
      end
    end
  end

  def black_puts_white_in_check?(player_color)
    black_pieces.any? do |piece|
      if @en_passant
        if piece.allowed_move?(white_king.location[0], white_king.location[1])
          path_to_horiz_vert_attack_clear?(piece.location[0], piece.location[1], player_color, white_king) ||
            path_to_diagonal_attack_clear?(piece.location[0], piece.location[1], player_color, white_king)
        end
      else
        attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece)
      end
    end
  end
end 