# frozen_string_literal: true

# code for handling castle moves
module CastleManager
  def assign_castle_targets(move, player_color)
    @castle_move = true
    @attack_move = false
    # destination row is always the same as starting row
    @dest_row = player_color == :white ? 7 : 0
    # with king side castle, king always ends up at column siz
    @dest_column = move.length == 3 ? 6 : 2
    assign_relevant_rook(move, player_color)
    @target = @squares[@dest_row][@dest_column]
    @found_piece = find_piece(move, player_color, @piece_type)
  end

  def assign_relevant_rook(move, player_color)
    # king side castle
    if move.length == 3
      @castle_type = :king_side
      # bottom-right
      @relevant_rook = @squares[7][7] if player_color == :white
      # top-right
      @relevant_rook = @squares[0][7] if player_color == :black
    # queen side castle
    else
      @castle_type = :queen_side
      # bottom-left
      @relevant_rook = @squares[7][0] if player_color == :white
      # top-left
      @relevant_rook = @squares[0][0] if player_color == :black
    end
  end

  def castle_white_or_black_king(player_color)
    @piece_found = true
    if player_color == :white
      assign_start_location(@squares[7][4])
      # white king
      @squares[7][4]
    else
      assign_start_location(@squares[0][4])
      # black king
      @squares[0][4]
    end
  end

  def castle_rules_followed?(player_color)
    king_and_rook = if player_color == :white
                      white_pieces.select { |piece| piece == @relevant_rook && castling_pair_legal?(piece) }
                    else
                      black_pieces.select { |piece| piece == @relevant_rook && castling_pair_legal?(piece) }
                    end
    all_castle_conditions_true?(king_and_rook, player_color)
  end

  def castling_pair_legal?(piece)
    @relevant_rook.is_a?(Rook) || piece.is_a?(King)
  end

  def all_castle_conditions_true?(king_and_rook, player_color)
    king_and_rook.all? { |king_rook| king_rook.num_moves.zero? } &&
      space_free_for_castle?(player_color) &&
      opponent_cannot_attack_castle_path?(player_color, @castle_type)
  end

  def opponent_cannot_attack_castle_path?(player_color, castle_type)
    @attack_move = true
    if player_color == :white
      white_castle_path_safe?(player_color, castle_type)
    else
      black_castle_path_safe?(player_color, castle_type)
    end
  end

  def white_castle_path_safe?(player_color, castle_type)
    if castle_type == :king_side
      cannot_attack_castle_path?(player_color, 7, 5)
    else
      cannot_attack_castle_path?(player_color, 7, 3)
    end
  end

  def black_castle_path_safe?(player_color, castle_type)
    if castle_type == :king_side
      cannot_attack_castle_path?(player_color, 0, 5)
    else
      cannot_attack_castle_path?(player_color, 0, 3)
    end
  end

  def cannot_attack_castle_path?(player_color, row, col)
    if player_color == :white
      castle_path_free_from_attack?(black_pieces, player_color, row, col)
    else
      castle_path_free_from_attack?(white_pieces, player_color, row, col)
    end
  end

  def castle_path_free_from_attack?(pieces, player_color, row, col)
    pieces.none? do |piece|
      piece.turn_attack_mode_on if piece.is_a?(Pawn)
      if piece.is_a?(Pawn) || piece.is_a?(Knight)
        piece.allowed_move?(row, col)
      else
        path_from_opponent_to_castle_path_clear?(piece, player_color, row, col)
      end
    end
  end

  def path_from_opponent_to_castle_path_clear?(piece, player_color, row, col)
    return unless piece.allowed_move?(row, col)

    piece_row = piece.location[0]
    piece_col = piece.location[1]

    if horizontal_vertical_move?(piece_row, piece_col, @squares[row][col])
      path_to_horiz_vert_attack_clear?(piece_row, piece_col, player_color, @squares[row][col])
    else
      path_to_diagonal_attack_clear?(piece_row, piece_col, player_color, @squares[row][col])
    end
  end

  def space_free_for_castle?(player_color)
    if @castle_type == :king_side
      king_side_space_free?(player_color)
    else
      queen_side_space_free?(player_color)
    end
  end

  def king_side_space_free?(player_color)
    if player_color == :white
      @squares[7][5..6].all? { |s| s.is_a?(EmptySquare) }
    else
      @squares[0][5..6].all? { |s| s.is_a?(EmptySquare) }
    end
  end

  def queen_side_space_free?(player_color)
    if player_color == :white
      @squares[7][1..3].all? { |s| s.is_a?(EmptySquare) }
    else
      @squares[0][1..3].all? { |s| s.is_a?(EmptySquare) }
    end
  end

  def reposition_rook(move)
    move.length == 3 ? reposition_king_side_rook : reposition_queen_side_rook
  end

  def reposition_king_side_rook
    return unless @relevant_rook.is_a?(Rook)

    rook_row = @relevant_rook.location[0]
    rook_col = @relevant_rook.location[1]
    @squares[@dest_row][@dest_column - 1] = @relevant_rook
    @squares[rook_row][rook_col] = EmptySquare.new([rook_row, rook_col])
    # new rook location is one column to the left of King's new position
    update_rook_location(-1)
  end

  def reposition_queen_side_rook
    return unless @relevant_rook.is_a?(Rook)

    rook_row = @relevant_rook.location[0]
    rook_col = @relevant_rook.location[1]
    @squares[@dest_row][@dest_column + 1] = @relevant_rook
    @squares[rook_row][rook_col] = EmptySquare.new([rook_row, rook_col])
    # new rook location is one column to the right of King's new position
    update_rook_location(1)
  end

  def update_rook_location(col_diff)
    @relevant_rook.update_location(@found_piece.location[0], @found_piece.location[1] + col_diff)
  end
end
