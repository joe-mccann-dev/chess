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

  def mark_kings_as_not_in_check
    white_king.mark_as_not_in_check
    black_king.mark_as_not_in_check
  end

  def move_puts_player_in_check?(player_color)
    reassign_relevant_board_variables(player_color)
    mark_king_as_in_check?(player_color)
  end

  def move_puts_self_in_check?(player_color)
    reassign_relevant_board_variables(opposite(player_color))
    mark_king_as_in_check?(opposite(player_color))
  end

  def opposite(player_color)
    player_color == :white ? :black : :white
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

  def king_moves_in_algebraic_notation(player_color, algebraic_notations = [])
    king = player_color == :white ? black_king : white_king
    king.available_squares.each do |square_location|
      row = translate_row_index_to_displayed_row(square_location[0])
      col = translate_column_index(square_location[1])
      if @squares[square_location[0]][square_location[1]].symbolic_color == player_color
        # include in x since attack mode should be on to simulate king attacking its way out of check
        # @attack_mode boolean switch in SetupBoardVariables 
        algebraic_notations << "Kx#{col}#{row}"
      else
        algebraic_notations << "K#{col}#{row}"
      end
    end
    algebraic_notations
  end

  # checkmate is false if check is blockable
  def check_blockable?(player_color)
    if player_color == :white
      pieces = black_pieces
      king = black_king
    else
      pieces = white_pieces
      king = white_king
    end
    search_for_potential_block(pieces, king, player_color)
  end

  # can any of opposite player's pieces capture or block the piece that put the king in check?
  def search_for_potential_block(pieces, king, player_color)
    binding.pry
    # determine if piece that put king in check can be captured
    # king can capture attacker if it doesn't put him in check
    can_be_captured = determine_if_attacker_can_be_captured(pieces, player_color)
    # see if the attacker's line of attack can be blocked
    # king can't block his own check
    can_be_blocked = determine_if_attacker_can_be_blocked(pieces.select { |p| !p.is_a?(King) }, king, player_color)
    can_be_captured || can_be_blocked
  end

  def determine_if_attacker_can_be_blocked(pieces, king, player_color)
    # knight cannot be blocked since pieces in path are irrelevant to a Knight and do not effect check
    return false if @active_piece.is_a?(Knight)
    
    @attack_move = false
    # check made in horizontal line. piece can block check-line at spaces from edge of king to edge of attacker
    pieces.any? do |p|
      attacker_col = @active_piece.location[1]
      col = attacker_col > king.location[1] ? king.location[1] + 1 : king.location[1] - 1
      row = king.location[0]
      while col < attacker_col
        result = regular_move_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
        break if result

        col += 1
      end
      result
    end
  end

  def determine_if_attacker_can_be_captured(pieces, player_color)
    @attack_move = true
    row = @active_piece.location[0]
    col = @active_piece.location[1]
    pieces.any? do |p|
      attack_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col]) &&
       !move_puts_player_in_check?(player_color)
    end
  end

  # put_in_check_via_row = king.location[0] == @active_piece.location[0]
  # put_in_check_via_col = king.location[1] == @active_piece.location[1]
end 