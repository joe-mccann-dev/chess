class Game
  def initialize(player1 = Player.new, player2 = Player.new, board = Board.new)
    @player1 = player1
    @player2 = player2
    @board = board
  end

  def start_game
    show_welcome_message
    print "Player 1, please enter your name: "
    @player1.request_name
    print "Player 2, please enter your name: "
    @player2.request_name
    @player1.request_color
    puts
    @player1.color == "\u2659".colorize(:black) ? @player2.assign_color(2) : @player2.assign_color(1)
  end

  def play_game
    @board.display
    # white enters algebraic notation such as "e4"
    puts "#{@player1.name}, please enter a destination square"
    # a method splits that entry, translates "e" to column, "4" to row
    @board.update_board
    # in this case, "e" is the 5th column, "4" is the row @squares[3]
    # black goes
  end

  def show_welcome_message
    puts <<-HEREDOC

      Welcome to Chess

      Win by placing your opponent's King in checkmate!

      Let's get started

    HEREDOC
  end
end
