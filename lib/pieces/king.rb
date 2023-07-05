# frozen_string_literal: true

# contains code for legal king movements
class King < Piece
  attr_reader :num_moves, :in_check

  def initialize(color, location, unicode = "\u2654")
    super
    @in_check = false
    @num_moves = 0
    @prefix = 'K'
  end

  ROW_MOVES = [1, -1, 1, -1, 1, -1, 0, 0].freeze
  COL_MOVES = [1, 1, -1, -1, 0, 0, 1, -1].freeze

  def row_moves
    ROW_MOVES
  end
  
  def col_moves
    COL_MOVES
  end

  def update_num_moves
    @num_moves += 1
  end

  def mark_as_in_check
    @in_check = true
  end

  def mark_as_not_in_check
    @in_check = false
  end
end

