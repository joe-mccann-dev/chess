# frozen_string_literal: true

# generates list of available squares to any given piece regardless of legality
module AdjacencyListGenerator
  def available_squares
    row = @location[0]
    col = @location[1]
    # necessary only to account for pawn attacks
    @attack_mode ? adj_attack_squares(row, col) : adj_squares(row, col)
  end

  def adj_squares(row, col)
    adj_list = []
    row_moves.length.times do |n|
      adj_list << [row + row_moves[n], col + col_moves[n]] if on_board?(row, row_moves[n], col, col_moves[n])
    end
    adj_list
  end

  def adj_attack_squares(row, col)
    adj_list = []
    attack_row_moves.length.times do |n|
      if on_board?(row, attack_row_moves[n], col, attack_col_moves[n])
        adj_list << [row + attack_row_moves[n], col + attack_col_moves[n]]
      end
    end
    adj_list
  end

  def on_board?(row, row_diff, col, col_diff)
    (row + row_diff).between?(0, 7) && (col + col_diff).between?(0, 7)
  end
end
