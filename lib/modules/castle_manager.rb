# frozen_string_literal: true

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
    player_color == :white ? @squares[7][4] : @squares [0][4]
    if player_color == :white
      assign_start_location(@squares[7][4])
      @squares[7][4]
    else
      assign_start_location(@squares[0][4])
      @squares[0][4]
    end
  end

  def castle_rules_followed?(player_color)
    king_and_rook = if player_color == :white
                      white_pieces.select { |piece| piece == @relevant_rook || piece.is_a?(King) }
                    else
                      black_pieces.select { |piece| piece == @relevant_rook || piece.is_a?(King) }
                    end
    all_castle_conditions_true?(king_and_rook, player_color)
  end

  def all_castle_conditions_true?(king_and_rook, player_color)
    king_and_rook.all? { |piece| piece.num_moves.zero? } &&
      space_free_for_castle?(player_color) && !@king_in_check
  end

  def space_free_for_castle?(player_color)
    if @castle_type == :king_side
      king_side_space_free?(player_color)
    else
      queen_side_space_free?(player_color)
    end
  end

  def king_side_space_free?(player_color)
    player_color == :white ? @squares[7][5..6].all?(' ') : @squares[0][5..6].all?(' ')
  end

  def queen_side_space_free?(player_color)
    player_color == :white ? @squares[7][1..3].all?(' ') : @squares[0][1..3].all?(' ')
  end

  def reposition_rook(move)
    move.length == 3 ? reposition_king_side_rook : reposition_queen_side_rook
  end

  def reposition_king_side_rook
    @squares[@dest_row][@dest_column - 1] = @relevant_rook
    @squares[@relevant_rook.location[0]][@relevant_rook.location[1]] = ' '
    # new rook location is one column to the left of King's new position
    @relevant_rook.update_location(@found_piece.location[0], @found_piece.location[1] - 1)
  end

  def reposition_queen_side_rook
    @squares[@dest_row][@dest_column + 1] = @relevant_rook
    @squares[@relevant_rook.location[0]][@relevant_rook.location[1]] = ' '
    # new rook location is one column to the right of King's new position
    @relevant_rook.update_location(@found_piece.location[0], @found_piece.location[1] + 1)
  end
end
