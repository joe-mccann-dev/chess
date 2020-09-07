class Game
  def initialize(player1 = Player.new, player2 = Player.new, board = Board.new)
    @player1 = player1
    @player2 = player2
    @board = board
  end

  def start_game
    show_welcome_message
    print "Player 1, please enter your name: "
    @player1.request_info
    puts
    print "Player 2, please enter your name: "
    @player2.request_info
    assign_player2_opposite_color
  end

  def show_welcome_message
    puts <<-HEREDOC

      "Welcome to Chess"

      "Win by placing your opponent's King in checkmate!"

      Let's get started

    HEREDOC
  end
end