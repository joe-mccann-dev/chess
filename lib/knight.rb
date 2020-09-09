class Knight
  attr_reader :color, :unicode, :capture

  def initialize(color, unicode = "\u265E")
    color == 1 ? @color = unicode.colorize(:light_yellow) : @color = unicode.colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end