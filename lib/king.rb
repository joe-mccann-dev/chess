# frozen_string_literal: true

class King
  include AdjacencyListGenerator
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location

  def initialize(color, location, unicode = "\u265A")
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
    [1, -1, 1, -1, 1, -1, 0, 0]
  end

  def col_moves
    [1, 1, -1, -1, 0, 0, 1, -1]
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
