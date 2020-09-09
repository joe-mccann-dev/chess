class King
  attr_reader :color, :unicode, :capture

  def initialize(color, unicode = "\u265A")
    color == 1 ? @color = unicode.colorize(:light_yellow) : @color = unicode.colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end