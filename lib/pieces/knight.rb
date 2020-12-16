# frozen_string_literal: true

# contains code for legal knight movements
class Knight < Piece
  def initialize(color, location, unicode = '♞')
    super
    @prefix = 'N'
  end

  def row_moves
    [1, -1, 1, -1, 2, -2, 2, -2]
  end

  def col_moves
    [2, 2, -2, -2, 1, 1, -1, -1]
  end
end
