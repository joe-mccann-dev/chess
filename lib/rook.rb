# frozen_string_literal: true

class Rook
  include AdjacencyListGenerator
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location, :num_moves

  def initialize(color, location, unicode = "\u265C")
    @captured = false
    @location = location
    @castle_mode = false
    @num_moves = 0
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
  end

  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
  end

  def row_moves
    (1..7).to_a + (-7..-1).to_a + Array.new(14) {0}
    # [1, 2, 3, 4, 5, 6, 7, -7, -6, -5, -4, -3, -2, -1, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0]
  end

  def col_moves
    Array.new(14) {0} + (1..7).to_a + (-7..-1).to_a
    # [0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0,  0,  0,  0, 1, 2, 3, 4, 5, 6, 7, -7, -6, -5, -4, -3, -2, -1]
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
