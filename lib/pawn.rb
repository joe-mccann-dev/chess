class Pawn
  attr_reader :color, :captured

  def initialize(color, unicode = "\u265F")
    color == 1 ? @color = unicode.colorize(:light_yellow) : @color = unicode.colorize(:cyan)
    @unicode = unicode
    @captured = false
  end

end