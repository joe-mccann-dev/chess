class Bishop
  attr_reader :color, :capture

  def initialize(color, unicode)
    color == 1 ? @color =  "\u265D".colorize(:light_yellow) : @color = "\u265D".colorize(:cyan)
    @unicode = unicode
    @captured = false
  end
end