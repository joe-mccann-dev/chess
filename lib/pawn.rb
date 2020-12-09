# frozen_string_literal: true

class Pawn
  include AdjacencyListGenerator
  include EnPassantManager

  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location, :attack_mode, :en_passant, 
              :just_moved_two, :num_moves, :prefix

  def initialize(color, location, unicode = "♟")
    @num_moves = 0
    @location = location
    @captured = false
    @attack_mode = false
    @en_passant = false
    @just_moved_two = false
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
    @prefix = ''
  end

  def row_moves
    if @symbolic_color == :white
      @num_moves == 0 ? [-1, -2] : [-1, 0]
    else
      @num_moves == 0 ? [1, 2] : [1, 0]
    end
  end

  def col_moves
    [0, 0]
  end

  def attack_row_moves
    @symbolic_color == :white ? [-1, -1] : [1, 1]
  end

  def attack_col_moves
    [1, -1]
  end

  def toggle_attack_mode(squares, start_row, start_column, dest_row, dest_column)
    @en_passant = false
    @attack_mode = attack_prerequisites_met?(squares, start_row, start_column, dest_row, dest_column)
  end

  def turn_attack_mode_on
    @attack_mode = true
  end

  def attack_prerequisites_met?(squares, start_row, start_column, dest_row, dest_column)
    if en_passant_move?(squares, start_row, start_column, dest_row, dest_column)
      @en_passant = true
      if @symbolic_color == :white 
        start_column != dest_column && !squares[dest_row + 1][dest_column].is_a?(EmptySquare)
      else
        start_column != dest_column && !squares[dest_row - 1][dest_column].is_a?(EmptySquare)
      end
    else
      start_column != dest_column && !squares[dest_row][dest_column].is_a?(EmptySquare)
    end
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

  def update_location(dest_row, dest_column)
    @location = [dest_row, dest_column]
  end

  def update_double_step_move(start_row, dest_row)
    @just_moved_two = (start_row - dest_row).abs == 2
  end

  def mark_as_captured
    @captured = true
  end
end
