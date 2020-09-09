class Rook
  attr_reader :color, :capture

  def initialize(color, unicode = "\u265C")
    color == 1 ? @color = unicode.colorize(:light_yellow) : @color = unicode.colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end