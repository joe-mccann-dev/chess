# frozen_string_literal: true

class Queen
  include AdjacencyListGenerator
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location

  def initialize(color, location, unicode = "\u265B")
    @captured = false
    @location = location
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
  end

  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
  end

  def row_moves
    # rook row_moves + bishop row_moves
    (1..7).to_a + (-7..-1).to_a + Array.new(14) {0} +
    (1..7).to_a + (-7..-1).to_a.reverse + (1..7).to_a + (-7..-1).to_a.reverse
  end

  def col_moves
    #rook col_moves + bishop col_moves
    Array.new(14) {0} + (1..7).to_a + (-7..-1).to_a +
    (1..7).to_a + (-7..-1).to_a.reverse + (-7..-1).to_a.reverse + (1..7).to_a
  end

  def allowed_move?(dest_row, dest_column)
    available_squares.include?([dest_row, dest_column])
  end

  def update_location(dest_row, column)
    @location = [dest_row, column]
  end
end
