class King
  attr_reader :color, :capture

  def initialize(color, unicode)
    color == 1 ? @color = "\u265A".colorize(:light_yellow) : @color = "\u265A".colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end