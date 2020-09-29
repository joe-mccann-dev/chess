# frozen_string_literal: true

class Knight
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location

  def initialize(color, location, unicode = "\u265E")
    @captured = false
    @location = location
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
  end

  def available_squares
    row = @location[0]
    col = @location[1]
    available_squares = adj_squares(row, col)
  end

  def adj_squares(row, col)
    squares = []
    dy = [1, -1, 1, -1, 2, -2, 2, -2]
    dx = [2, 2, -2, -2, 1, 1, -1, -1]
    8.times do |n|
      squares << [row + dy[n], col + dx[n]] if on_board?(row, dy[n], col, dx[n])
    end
    squares
  end

  def on_board?(row, row_diff, col, col_diff)
    (row + row_diff).between?(0, 7) && (col + col_diff).between?(0, 7)
  end

  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
  end

  def allowed_move?(dest_row, dest_column)
    available_squares.include?([dest_row, dest_column])
  end

  def update_location(dest_row, column)
    @location = [dest_row, column]
  end
end
