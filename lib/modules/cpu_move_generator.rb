# frozen_string_literal: true

module CPUMoveGenerator
  def generate_cpu_moves(cpu_color)
    pieces = cpu_color == :black ? black_pieces : white_pieces
    opposite_color_pieces = cpu_color == :black ? white_pieces : black_pieces
    king = cpu_color == :black ? black_king : white_king
    empty_squares = find_empty_squares
    regular_moves = find_regular_moves(empty_squares, pieces)
    attack_moves = find_attack_moves(cpu_color, opposite_color_pieces, pieces)
    regular_moves + attack_moves
  end

  def find_empty_squares(empty_squares = [])
    @squares.each do |row|
      row.each { |s| empty_squares << s if s.is_a?(EmptySquare)}
    end
    empty_squares
  end

  def find_regular_moves(empty_squares, pieces, moves = [])
    empty_squares.each do |square|
      dest_row = square.location[0]
      dest_col = square.location[1]
      pieces.each do |piece|
        display_row = translate_row_index_to_displayed_row(dest_row)
        display_col = translate_column_index(dest_col)
        if regular_move_rules_followed?(piece.location[0], piece.location[1], piece, @squares[dest_row][dest_col])
          moves << "#{piece.prefix}#{display_col}#{display_row}"
        end
      end
    end
    # include castle_moves as possibility
    moves
  end

  def find_attack_moves(cpu_color, opposite_color_pieces, pieces, moves = [])
    opposite_color_pieces.each do |square_with_opponent_piece|
      dest_row = square_with_opponent_piece.location[0]
      dest_col = square_with_opponent_piece.location[1]
      pieces.each do |piece|
        display_row = translate_row_index_to_displayed_row(dest_row)
        display_col = translate_column_index(dest_col)
        if attack_rules_followed?(piece.location[0], piece.location[1], cpu_color, piece, @squares[dest_row][dest_col])
          if piece.is_a?(Pawn)
            pawn_start_column = translate_column_index(piece.location[1])
            moves << "#{pawn_start_column}#{piece.prefix}x#{display_col}#{display_row}"
          else
            moves << "#{piece.prefix}x#{display_col}#{display_row}"
          end
        end
      end
    end
    moves
  end

  def toggle_cpu_mode(player)
    @cpu_mode = player.name == 'CPU'
  end
end