# frozen_string_literal: true

# contains code for legal Queen movements
class Queen < Piece

  def initialize(color, location, unicode = '♛')
    super
    @prefix = 'Q'
  end

  def row_moves
    # rook row_moves + bishop row_moves
    (1..7).to_a + (-7..-1).to_a + Array.new(14) { 0} +
      (1..7).to_a + (-7..-1).to_a.reverse + (1..7).to_a + (-7..-1).to_a.reverse
  end

  def col_moves
    # rook col_moves + bishop col_moves
    Array.new(14) {0} + (1..7).to_a + (-7..-1).to_a +
      (1..7).to_a + (-7..-1).to_a.reverse + (-7..-1).to_a.reverse + (1..7).to_a
  end
end
