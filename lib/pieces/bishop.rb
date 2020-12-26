# frozen_string_literal: true

# contains code for legal Bishop movements
class Bishop < Piece
  def initialize(color, location, unicode = '♝')
    super
    @prefix = 'B'
  end

  def row_moves
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7
    ]
  end

  def col_moves 
    [
      1,  2,  3,  4,  5,  6,  7,
     -1, -2, -3, -4, -5, -6, -7,
     -1, -2, -3, -4, -5, -6, -7,
      1,  2,  3,  4,  5,  6,  7
    ]
  end
end
