# frozen_string_literal: true

# contains code for legal Rook movements
class Rook < Piece
  attr_reader :num_moves

  def initialize(color, location, unicode = "\u2656")
    super
    @num_moves = 0
    @prefix = 'R'
  end

  ROW_MOVES =
    [
      1,  2,  3,  4,  5,  6,  7,
     -7, -6, -5, -4, -3, -2, -1,
      0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0
    ].freeze
  
  COL_MOVES =
    [
      0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,
      1,  2,  3,  4,  5,  6,  7,
     -7, -6, -5, -4, -3, -2, -1
    ].freeze
  
  def row_moves
    ROW_MOVES
  end

  def col_moves
    COL_MOVES
  end

  def update_num_moves
    @num_moves += 1
  end
end
