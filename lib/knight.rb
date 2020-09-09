class Knight
  attr_reader :color, :capture

  def initialize(color, unicode)
    color == 1 ? @color = "\u265E".colorize(:light_yellow) : @color = "\u265E".colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end