# frozen_string_literal: true

class Pawn
  include AdjacencyListGenerator
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location

  def initialize(color, location, unicode = "\u265F")
    @num_moves = 0
    @location = location
    @captured = false
    @attack_mode = false
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
  end

  def row_moves
    if @symbolic_color == :white
      @num_moves == 0 ? [-1, -2] : [-1, 0]
    else
      @num_moves == 0 ? [1, 2] : [1, 0]
    end
  end

  # TODO - add column restrictions once ability to attack is created
  def col_moves
    [0, 0]
  end

  def attack_row_moves
    @symbolic_color == :white ? [-1, -1] : [1, 1]
  end

  def attack_col_moves
    [1, -1]
  end

  def toggle_attack_mode(start_column, dest_column)
    @attack_mode = start_column != dest_column
  end
  
  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
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

  def mark_as_captured
    @captured = true
  end
end
