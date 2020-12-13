# frozen_string_literal: true

class King
  include AdjacencyListGenerator
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location, :num_moves, :in_check, :prefix

  def initialize(color, location, unicode = '♚')
    @captured = false
    @location = location
    @in_check = false
    @num_moves = 0
    @displayed_color = color == 1 ? unicode.colorize(:light_yellow) : unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
    @prefix = 'K'
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

  def update_num_moves
    @num_moves += 1
  end

  def update_location(dest_row, column)
    @location = [dest_row, column]
  end

  def mark_as_in_check
    @in_check = true
  end

  def mark_as_not_in_check
    @in_check = false
  end

  def mark_as_captured
    @captured = true
  end
end
