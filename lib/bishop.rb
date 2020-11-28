# frozen_string_literal: true

class Bishop
  include AdjacencyListGenerator
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location, :prefix

  def initialize(color, location, unicode = "\u265D")
    @captured = false
    @location = location
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
    @prefix = 'B'
  end

  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
  end

  def row_moves
    # [1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7,  1,  2,  3,  4,  5,  6,  7, -1, -2, -3, -4, -5, -6, -7]
    (1..7).to_a + (-7..-1).to_a.reverse + (1..7).to_a + (-7..-1).to_a.reverse
  end

  def col_moves
    # [1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7, -1, -2, -3, -4, -5, -6, -7,  1,  2,  3,  4,  5,  6,  7]
    (1..7).to_a + (-7..-1).to_a.reverse + (-7..-1).to_a.reverse + (1..7).to_a
  end

  def allowed_move?(dest_row, dest_column)
    available_squares.include?([dest_row, dest_column])
  end

  def update_location(dest_row, column)
    @location = [dest_row, column]
  end
  
  def mark_as_captured
    @captured = true
  end
end
