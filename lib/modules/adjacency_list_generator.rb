# frozen_string_literal: true

module AdjacencyListGenerator
  def available_squares
    row = @location[0]
    col = @location[1]
    available_squares = adj_squares(row, col)
  end

  def adj_squares(row, col)
    adj_list = []
    row_moves.length.times do |n|
      if on_board?(row, row_moves[n], col, col_moves[n])
        adj_list << [row + row_moves[n], col + col_moves[n]]
      end
    end
    adj_list
  end

  def on_board?(row, row_diff, col, col_diff)
    (row + row_diff).between?(0, 7) && (col + col_diff).between?(0, 7)
  end
end