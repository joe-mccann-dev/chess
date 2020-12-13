# frozen_string_literal: true

module CPUMoveGenerator
  def generate_cpu_moves(cpu_color, checking_for_stalemate = false)
    pieces = determine_piece_set(cpu_color, checking_for_stalemate)
    opposite_color_pieces = cpu_color == :black ? white_pieces : black_pieces
    king = cpu_color == :black ? black_king : white_king
    empty_squares = find_empty_squares
    regular_moves = find_regular_moves(empty_squares, pieces, checking_for_stalemate)
    attack_moves = find_attack_moves(cpu_color, opposite_color_pieces, pieces)
    @cpu_moves = regular_moves + attack_moves
  end

  def determine_piece_set(color, checking_for_stalemate = nil)
    if checking_for_stalemate
      # e.g., white moves and potentially puts black in stalemate, can black move any other pieces?
      color == :white ? black_pieces.reject { |p| p.is_a?(King) } : white_pieces.reject { |p| p.is_a?(King) }
    else
      color == :black ? black_pieces : white_pieces
    end
  end

  def find_empty_squares(empty_squares = [])
    @squares.each do |row|
      row.each { |s| empty_squares << s if s.is_a?(EmptySquare) }
    end
    empty_squares
  end

  def find_regular_moves(empty_squares, pieces, _checking_for_stalemate, moves = [])
    empty_squares.each do |square|
      dest_row = square.location[0]
      dest_col = square.location[1]
      pieces.each do |p|
        display_row = translate_row_index_to_displayed_row(dest_row)
        display_col = translate_col_index_to_displayed_col(dest_col)
        p.toggle_attack_mode(@squares, p.location[0], p.location[1], dest_row, dest_col) if p.is_a?(Pawn)
        if regular_move_rules_followed?(p.location[0], p.location[1], p, @squares[dest_row][dest_col])
          moves << "#{p.prefix}#{display_col}#{display_row}"
        end
      end
    end
    moves
  end

  def find_attack_moves(cpu_color, opposite_color_pieces, pieces, moves = [])
    opposite_color_pieces.each do |square_with_opponent_piece|
      dest_row = square_with_opponent_piece.location[0]
      dest_col = square_with_opponent_piece.location[1]
      pieces.each do |piece|
        @attack_move = true
        display_row = translate_row_index_to_displayed_row(dest_row)
        display_col = translate_col_index_to_displayed_col(dest_col)
        if attack_rules_followed?(piece.location[0], piece.location[1], cpu_color, piece, @squares[dest_row][dest_col])
          if piece.is_a?(Pawn)
            pawn_start_column = translate_col_index_to_displayed_col(piece.location[1])
            moves << "#{pawn_start_column}#{piece.prefix}x#{display_col}#{display_row}"
          else
            moves << "#{piece.prefix}x#{display_col}#{display_row}"
          end
        end
      end
    end
    moves
  end
end
