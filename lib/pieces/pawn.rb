# frozen_string_literal: true

# contains code for legal Pawn movements
class Pawn < Piece
  include EnPassantManager
  attr_reader :attack_mode, :en_passant, :just_moved_two, :num_moves

  def initialize(color, location, unicode = '♟')
    super
    @num_moves = 0
    @attack_mode = false
    @en_passant = false
    @just_moved_two = false
    @prefix = ''
  end

  def row_moves
    if @symbolic_color == :white
      @num_moves.zero? ? [-1, -2] : [-1, 0]
    else
      @num_moves.zero? ? [1, 2] : [1, 0]
    end
  end

    def attack_row_moves
    @symbolic_color == :white ? [-1, -1] : [1, 1]
  end

  COL_MOVES = [0, 0].freeze
  ATTACK_COL_MOVES = [1, -1].freeze

  def col_moves
    COL_MOVES
  end

  def attack_col_moves
    ATTACK_COL_MOVES
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
      attack_en_passant?(squares, start_column, dest_column, dest_row)
    else
      start_column != dest_column && !squares[dest_row][dest_column].is_a?(EmptySquare)
    end
  end

  def attack_en_passant?(squares, start_column, dest_column, dest_row)
    if @symbolic_color == :white
      start_column != dest_column && !squares[dest_row + 1][dest_column].is_a?(EmptySquare)
    else
      start_column != dest_column && !squares[dest_row - 1][dest_column].is_a?(EmptySquare)
    end
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
end
