# frozen_string_literal: true

# contains code for legal Queen movements
class Queen < Piece
  def initialize(color, location, unicode = '♛')
    super
    @prefix = 'Q'
  end

  ROW_MOVES =
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
     -7, -6, -5, -4, -3, -2, -1,
      0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0
    ].freeze

  COL_MOVES =
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
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
end
