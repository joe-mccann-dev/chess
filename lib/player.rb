class Player

  def initialize(color)
    color == 1 ? @color = WHITE : @color = BLACK
  end
  
  WHITE = "\u2659".colorize(:black)
  BLACK = "\u265F".colorize(:black)

end