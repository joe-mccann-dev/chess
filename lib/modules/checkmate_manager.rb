# frozen_string_literal: true

# contains methods that evaluate check and check-escapability
module CheckmateManager
  def white_king
    white_pieces.select { |piece| piece.is_a?(King) }[0]
  end

  def black_king
    black_pieces.select { |piece| piece.is_a?(King) }[0]
  end

  def other_player_in_check?(player_color)
    assign_king_as_target(player_color)
    mark_king_as_in_check?(player_color)
  end

  def self_in_check?(player_color)
    assign_king_as_target(opposite(player_color))
    mark_king_as_in_check?(opposite(player_color))
  end

  def assign_king_as_target(player_color)
    @checking_for_check = true
    @attack_move = true
    if player_color == :white
      @dest_row = black_king.location[0]
      @dest_column = black_king.location[1]
    else
      @dest_row = white_king.location[0]
      @dest_column = white_king.location[1]
    end
    @target = @squares[@dest_row][@dest_column]
  end

  def mark_king_as_in_check?(player_color)
    mark_kings_as_not_in_check
    king = player_color == :white ? black_king : white_king
    pieces = player_color == :white ? white_pieces : black_pieces
    king.mark_as_in_check if results_in_check?(player_color, pieces, king)
    check?
  end

  def check?
    white_king.in_check || black_king.in_check
  end

  def mark_kings_as_not_in_check
    white_king.mark_as_not_in_check
    black_king.mark_as_not_in_check
  end

  def results_in_check?(player_color, pieces, king, target = @target)
    pieces.any? do |piece|
      attacker_row = piece.location[0]
      attacker_col = piece.location[1]
      # need extra method for en_passant moves to prevent an en_passant move from putting self in check
      if @en_passant
        en_passant_move_results_in_check?(player_color, attacker_row, attacker_col, piece, king)
      else
        attack_rules_followed?(attacker_row, attacker_col, player_color, piece, target)
      end
    end
  end

  def en_passant_move_results_in_check?(player_color, attacker_row, attacker_col, piece, king)
    return unless piece.allowed_move?(king.location[0], king.location[1])

    path_to_horiz_vert_attack_clear?(attacker_row, attacker_col, player_color, king) ||
      path_to_diagonal_attack_clear?(attacker_row, attacker_col, player_color, king)
  end

  def king_moves_in_algebraic_notation(player_color, algebraic_notations = [])
    king = player_color == :white ? black_king : white_king
    king.available_squares.each do |location|
      row = translate_row_index_to_displayed_row(location[0])
      col = translate_column_index(location[1])
      king_dest_square = @squares[location[0]][location[1]]
      if king_dest_square.symbolic_color == player_color
        # include in x since attack mode should be on to simulate king attacking its way out of check
        algebraic_notations << "Kx#{col}#{row}"
      elsif available_location?(location[0], location[1], king, king_dest_square)
        algebraic_notations << "K#{col}#{row}"
      end
    end
    algebraic_notations
  end

  # checkmate is false if attacker can be blocked or captured
  def can_block_or_capture?(player_color, found_piece)
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
    can_be_captured = attacker_can_be_captured?(pieces, player_color, found_piece)
    # see if the attacker's line of attack can be blocked
    # king can't block his own check
    can_be_blocked = attacker_can_be_blocked?(pieces.reject { |p| p.is_a?(King) }, king, found_piece)
    # if attacker can be captured or blocked, then checkmate is false and game continues
    can_be_captured || can_be_blocked
  end

  # can defender capture the piece that just put king in check
  def attacker_can_be_captured?(pieces, player_color, found_piece)
    @checking_for_check = false
    row = found_piece.location[0]
    col = found_piece.location[1]
    pieces.any? do |p|
      @attack_move = true
      # if p is a king, then he cannot capture a piece if it puts him in check.
      # in this case, if he captures the found_piece ( the attacker located at @squares[row][col] ),
      # then if any attacking pieces can go to square the king wants to capture,
      # then attacker cannot be captured.
      next if p.is_a?(King) && opponent_pieces_can_attack_where_king_would_capture?(player_color, row, col)

      attack_rules_followed?(p.location[0], p.location[1], opposite(player_color), p, @squares[row][col])
    end
  end

  def opponent_pieces_can_attack_where_king_would_capture?(player_color, row, col)
    pieces = player_color == :white ? white_pieces : black_pieces
    # use a placeholder so that a regular move is simulated
    # (#attack_rules_follwed? would return false since attacker and @squares[row][col] would be the same color)
    # the important idea is that if the piece can go there normally, it can also attack that square
    placeholder = EmptySquare.new([row, col])
    pieces.any? do |p|
      # second conditional necessary d/t how I coded Pawn adjacency list
      regular_move_rules_followed?(p.location[0], p.location[1], p, placeholder) && p.location != [row, col]
    end
  end

  # all King_moves will either be EmptySquares or opponent pieces that he can attack
  def pieces_can_attack_king_moves?(row, col, player_color)
    @checking_for_check = true
    dest_square = @squares[row][col]
    pieces = player_color == :white ? white_pieces : black_pieces
    pieces.any? do |p|
      # check if any White pieces can attack blank_square King destination
      if dest_square.is_a?(EmptySquare)
        # need to turn_attack_mode_on for Pawns so that AdjacencyListGenerator
        # accurately reflects the pawn's available_squares
        # just need to test if pawn can go to the EmptySquare,
        # therefore I used #regular_move_rules_followed? instead of #attack_rules_followed?
        p.turn_attack_mode_on if p.is_a?(Pawn)
        regular_move_rules_followed?(p.location[0], p.location[1], p, dest_square)
      # King destination is a White piece threatened by Black King
      else
        piece_can_attack_where_king_attacks?(p, dest_square, row, col)
      end
    end
  end

  # can a piece attack King after he captures the piece at @squares[row][col]
  def piece_can_attack_where_king_attacks?(piece, dest_square, row, col)
    return piece.allowed_move?(row, col) if piece.is_a?(Knight)

    attacker_row = piece.location[0]
    attacker_col = piece.location[1]
    non_knight_piece_can_attack_where_king_attacks?(attacker_row, attacker_col, dest_square)
  end

  def non_knight_piece_can_attack_where_king_attacks?(attacker_row, attacker_col, dest_square)
    # turn attack_move on so that occupation of square by same color doesn't throw things off
    # e.g. White can't attack a square occupied by another White piece
    # can't use #attack_rules_followed? for this reason, as it relies on target being opposite color
    @attack_move = true
    if horizontal_vertical_move?(attacker_row, attacker_col, dest_square)
      column_has_space_for_move?(attacker_row, attacker_col, dest_square) &&
        row_has_space_for_move?(attacker_row, attacker_col, dest_square)
    else
      diagonal_has_space_for_move?(attacker_row, attacker_col, dest_square)
    end
  end

  def attacker_can_be_blocked?(pieces, king, found_piece)
    # knight cannot be blocked since pieces in path are irrelevant to a Knight and do not effect check
    return false if found_piece.is_a?(Knight)

    @attack_move = false
    attacker_row = found_piece.location[0]
    attacker_col = found_piece.location[1]
    # horizontal attack
    if attacker_row == king.location[0]
      can_be_blocked_horizontally?(pieces, king, attacker_col)
    # vertical attack
    elsif attacker_col == king.location[1]
      can_be_blocked_vertically?(pieces, king, attacker_row)
    else
      can_be_blocked_diagonally?(pieces, king, attacker_row, attacker_col)
    end
  end

  # check made in horizontal line. piece can block check-line at spaces from edge of king to edge of attacker
  def can_be_blocked_horizontally?(pieces, king, attacker_col)
    if attacker_col > king.location[1]
      can_be_blocked_on_right?(pieces, king, attacker_col)
    else
      can_be_blocked_on_left?(pieces, king, attacker_col)
    end
  end

  def can_be_blocked_on_right?(pieces, king, attacker_col)
    pieces.each do |p|
      col = king.location[1] + 1
      row = king.location[0]
      while col < attacker_col
        return true if regular_move_rules_followed?(p.location[0], p.location[1], p, @squares[row][col])

        col += 1
      end
    end
    false
  end

  def can_be_blocked_on_left?(pieces, king, attacker_col)
    pieces.each do |p|
      col = king.location[1] - 1
      row = king.location[0]
      while col > attacker_col
        return true if regular_move_rules_followed?(p.location[0], p.location[1], p, @squares[row][col])

        col -= 1
      end
    end
    false
  end

  def can_be_blocked_vertically?(pieces, king, attacker_row)
    # e.g white Qe2 puts black Ke8 in check
    if attacker_row > king.location[0]
      # technically below since @squares[0] is first row, but named it "above" because row[0] is row 8 on the display
      can_be_blocked_above?(pieces, king, attacker_row)
    else
      can_be_blocked_below?(pieces, king, attacker_row)
    end
  end

  def can_be_blocked_above?(pieces, king, attacker_row)
    pieces.each do |p|
      row = king.location[0] + 1
      col = king.location[1]
      while row < attacker_row
        return true if regular_move_rules_followed?(p.location[0], p.location[1], p, @squares[row][col])

        row += 1
      end
    end
    false
  end

  def can_be_blocked_below?(pieces, king, attacker_row)
    pieces.each do |p|
      row = king.location[0] - 1
      col = king.location[1]
      while row > attacker_row
        return true if regular_move_rules_followed?(p.location[0], p.location[1], p, @squares[row][col])

        row -= 1
      end
    end
    false
  end

  def can_be_blocked_diagonally?(pieces, king, attacker_row, attacker_col)
    move_distance = (attacker_col - king.location[1]).abs
    path = if attacker_row > king.location[0]
             ne_nw_diagonal_objects(attacker_row, attacker_col, move_distance, king)
           else
             se_sw_diagonal_objects(attacker_row, attacker_col, move_distance, king)
           end
    piece_reaches_diagonal?(pieces, path)
  end

  def piece_reaches_diagonal?(pieces, path)
    pieces.each do |p|
      path.each do |s|
        row = s.location[0]
        col = s.location[1]
        return true if regular_move_rules_followed?(p.location[0], p.location[1], p, @squares[row][col])
      end
    end
    false
  end

  def opposite(player_color)
    player_color == :white ? :black : :white
  end
end
