# frozen_string_literal: true

class Queen
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

  # def allowed_move?(start_row, dest_row, _player_color, start_column = nil, dest_column = nil)
  #   (start_row - dest_row).abs <= 7 && (start_column - dest_column).abs <= 7
  # end

  def allowed_move?(dest_row, dest_column)
    
  end

  def update_location(dest_row, column)
    @location = [dest_row, column]
  end
end
