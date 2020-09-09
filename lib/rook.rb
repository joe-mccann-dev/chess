class Rook
  attr_reader :color, :capture

  def initialize(color, unicode)
    color == 1 ? @color = "\u265C".colorize(:light_yellow) : @color = "\u265C".colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end