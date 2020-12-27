# frozen_string_literal: true

# contains code for legal Bishop movements
class Bishop < Piece
  def initialize(color, location, unicode = '♝')
    super
    @prefix = 'B'
  end

  ROW_MOVES = 
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7
    ].freeze

  COL_MOVES = 
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7
    ].freeze

  def row_moves
    ROW_MOVES
  end

  def col_moves
    COL_MOVES
  end
end
