# frozen_string_literal: true

# contains code for legal knight movements
class Knight < Piece
  def initialize(color, location, unicode = "\u2658")
    super
    @prefix = 'N'
  end

  ROW_MOVES = [1, -1, 1, -1, 2, -2, 2, -2].freeze
  COL_MOVES = [2, 2, -2, -2, 1, 1, -1, -1].freeze
  
  def row_moves
    ROW_MOVES
  end

  def col_moves
    COL_MOVES
  end
end
