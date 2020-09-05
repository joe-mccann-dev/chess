class Game
  def initialize(white = Player.new, black = Player.new, board = Board.new)
    @white = white
    @black = black
    @board = board
  end
end