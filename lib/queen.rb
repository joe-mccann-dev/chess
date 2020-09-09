class Queen
  attr_reader :color, :capture

  def initialize(color, unicode)
    color == 1 ? @color = "\u265B".colorize(:light_yellow) : @color = "\u265B".colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end