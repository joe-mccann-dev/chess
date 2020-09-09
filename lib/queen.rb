class Queen
  attr_reader :color, :capture

  def initialize(color, unicode = "\u265B")
    color == 1 ? @color = unicode.colorize(:light_yellow) : @color = unicode.colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end