# frozen_string_literal: true

module CheckmateManager
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

  def white_puts_black_in_check?(player_color, target = @target)
    white_pieces.any? do |piece|
      # need extra if statement for en_passant moves to prevent an en_passant move from putting self in check
      if @en_passant
        if piece.allowed_move?(black_king.location[0], black_king.location[1])
          path_to_horiz_vert_attack_clear?(piece.location[0], piece.location[1], player_color, black_king) ||
            path_to_diagonal_attack_clear?(piece.location[0], piece.location[1], player_color, black_king)
        end
      else
        attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece, target)
      end
    end
  end

  def black_puts_white_in_check?(player_color, target = @target)
    black_pieces.any? do |piece|
      # need extra if statement for en_passant moves to prevent an en_passant move from putting self in check
      if @en_passant
        if piece.allowed_move?(white_king.location[0], white_king.location[1])
          path_to_horiz_vert_attack_clear?(piece.location[0], piece.location[1], player_color, white_king) ||
            path_to_diagonal_attack_clear?(piece.location[0], piece.location[1], player_color, white_king)
        end
      else
        attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece, target)
      end
    end
  end

  def king_moves_in_algebraic_notation(player_color, algebraic_notations = [])
    king = player_color == :white ? black_king : white_king
    king.available_squares.each do |location|
      row = translate_row_index_to_displayed_row(location[0])
      col = translate_column_index(location[1])
      if @squares[location[0]][location[1]].symbolic_color == player_color
        # include in x since attack mode should be on to simulate king attacking its way out of check
        # @attack_mode boolean switch in SetupBoardVariables 
        algebraic_notations << "Kx#{col}#{row}"
      else
        if available_location?(location[0], location[1], king, @squares[location[0]][location[1]])
          algebraic_notations << "K#{col}#{row}"
        end
      end
    end
    algebraic_notations
  end

  # checkmate is false if a check is blockable
  def check_blockable?(player_color, found_piece)
    if player_color == :white
      pieces = black_pieces
      king = black_king
    else
      pieces = white_pieces
      king = white_king
    end
    allowed_to_block_or_capture?(pieces, king, player_color, found_piece)
  end

  # can any of opposite player's pieces capture or block the piece that put the king in check?
  # e.g. if white puts black king in check, can any black pieces capture or block the piece making the check
  def allowed_to_block_or_capture?(pieces, king, player_color, found_piece)
    binding.pry
    # determine if piece that put king in check can be captured
    # a piece or king can capture attacker if the capture doesn't place king in check
    can_be_captured = if player_color == :white
                        attacker_can_be_captured?(pieces, player_color, found_piece) 
                        # && 
                        #   !white_puts_black_in_check?(player_color, king)
                      else
                        attacker_can_be_captured?(pieces, player_color, found_piece) 
                        # && 
                        #   !black_puts_white_if_check?(player_color, king)
                      end
    puts "can be captured: #{can_be_captured}"
    # see if the attacker's line of attack can be blocked
    # king can't block his own check
    can_be_blocked = attacker_can_be_blocked?(pieces.select { |p| !p.is_a?(King) }, king, player_color, found_piece)
    # if attacker can be captured or blocked, then checkmate is false and game continues
    can_be_captured || can_be_blocked
  end

  def attacker_can_be_captured?(pieces, player_color, found_piece)
    @attack_move = true
    row = found_piece.location[0]
    col = found_piece.location[1]
    pieces.any? do |p|
      attack_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
    end
  end

  def attacker_can_be_blocked?(pieces, king, player_color, found_piece)
    # knight cannot be blocked since pieces in path are irrelevant to a Knight and do not effect check
    return false if found_piece.is_a?(Knight)

    @attack_move = false
    attacker_row = found_piece.location[0]
    attacker_col = found_piece.location[1]
    puts "attacker row == king row #{attacker_row == king.location[0]}"
    # horizontal attack
    if attacker_row == king.location[0]
      can_be_blocked_horizontally?(pieces, king, player_color, attacker_col)
    # vertical attack
    elsif attacker_col == king.location[1]
      can_be_blocked_vertically?(pieces, king, player_color, attacker_row)
    else
      can_be_blocked_diagonally?(pieces, king, player_color, attacker_row, attacker_col)
    end
  end

  # check made in horizontal line. piece can block check-line at spaces from edge of king to edge of attacker
  def can_be_blocked_horizontally?(pieces, king, player_color, attacker_col)
    if attacker_col > king.location[1]
      can_be_blocked_on_right?(pieces, king, player_color, attacker_col)
    else
      can_be_blocked_on_left?(pieces, king, player_color, attacker_col)
    end
  end

  def can_be_blocked_on_right?(pieces, king, player_color, attacker_col)
    pieces.any? do |p|
      col = king.location[1] + 1
      row = king.location[0]
      while col < attacker_col
        result = regular_move_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
        break if result

        col += 1
      end
      result
    end
  end

  def can_be_blocked_on_left?(pieces, king, player_color, attacker_col)
    pieces.any? do |p|
      col = king.location[1] - 1
      row = king.location[0]
      while col > attacker_col
        result = regular_move_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
        break if result

        col -= 1
      end
      result
    end
  end

  def can_be_blocked_vertically?(pieces, king, player_color, attacker_row)
    # e.g white Qe2 puts black Ke8 in check
    if attacker_row > king.location[0]
      # technically below since @squares[0] is first row, but named it "above" because row[0] is row 8 on the display
      can_be_blocked_above?(pieces, king, player_color, attacker_row)
    else
      can_be_blocked_below?(pieces, king, player_color, attacker_row)
    end
  end

  def can_be_blocked_above?(pieces, king, player_color, attacker_row)
    pieces.any? do |p|
      row = king.location[0] + 1
      col = king.location[1]
      while row < attacker_row
        result = regular_move_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
        break if result

        row += 1
      end
      result
    end
  end

  def can_be_blocked_below?(pieces, king, player_color, attacker_row)
    pieces.any? do |p|
      row = king.location[0] - 1
      col = king.location[1]
      while row > attacker_row
        result = regular_move_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
        break if result

        row -= 1
      end
      result
    end
  end

  def can_be_blocked_diagonally?(pieces, king, player_color, attacker_row, attacker_col)
    move_distance = (attacker_col - king.location[1]).abs
    path = if attacker_row > king.location[0]
             ne_nw_diagonal_objects(attacker_row, attacker_col, move_distance, king)
           else
             se_sw_diagonal_objects(attacker_row, attacker_col, move_distance, king)
           end
    piece_reaches_diagonal?(pieces, path, player_color)
  end

  def piece_reaches_diagonal?(pieces, path, player_color)
    pieces.any? do |p|
      path.each do |s|
        row = s.location[0]
        col = s.location[1]
        if regular_move_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
          return true

        end
      end
    end
    false
  end
end 