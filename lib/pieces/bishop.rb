# frozen_string_literal: true

# contains code for legal Bishop movements
class Bishop < Piece
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location, :prefix

  def initialize(color, location, unicode = '♝')
    @captured = false
    @location = location
    @displayed_color = color == 1 ? unicode.colorize(:light_yellow) : unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
    @prefix = 'B'
  end

  def row_moves
    # [1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7,  1,  2,  3,  4,  5,  6,  7, -1, -2, -3, -4, -5, -6, -7]
    (1..7).to_a + (-7..-1).to_a.reverse + (1..7).to_a + (-7..-1).to_a.reverse
  end

  def col_moves
    # [1, 2, 3, 4, 5, 6, 7, -1, -2, -3, -4, -5, -6, -7, -1, -2, -3, -4, -5, -6, -7,  1,  2,  3,  4,  5,  6,  7]
    (1..7).to_a + (-7..-1).to_a.reverse + (-7..-1).to_a.reverse + (1..7).to_a
  end
end
