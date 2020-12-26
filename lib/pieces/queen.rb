# frozen_string_literal: true

# contains code for legal Queen movements
class Queen < Piece
  def initialize(color, location, unicode = '♛')
    super
    @prefix = 'Q'
  end

  def row_moves
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
     -7, -6, -5, -4, -3, -2, -1,
      0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0
    ]
  end

  def col_moves
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
      0,  0,  0,  0,  0,  0,  0,
      0,  0,  0,  0,  0,  0,  0,
      1,  2,  3,  4,  5,  6,  7,
     -7, -6, -5, -4, -3, -2, -1
    ]
  end
end
