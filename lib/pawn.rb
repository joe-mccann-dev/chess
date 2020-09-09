class Pawn
  attr_reader :color, :captured

  def initialize(color, unicode)
    color == 1 ? @color = "\u265F".colorize(:light_yellow) : @color = "\u265F".colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end