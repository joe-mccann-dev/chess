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
    if @player1.color == "\u265F".colorize(:light_yellow)
      @player2.assign_color(2)
    else
      @player2.assign_color(1)
    end
    @board.display
    player1_turn
    @board.display 
    
  end

  def player1_turn
    player1_move = request_player1_move
    loop do
      break if @board.valid_move?(player1_move)

      puts 'column unavailable. please select again...'
      player1_move = request_player1_move
    end
    @board.update_board(player1_move, @player1.color)
  end
  
  def request_player1_move
    print "#{@player1.name}, please enter a move in algebraic notation: "
    gets.chomp
  end

  def show_welcome_message
    puts <<-HEREDOC

      Welcome to Chess

      Win by placing your opponent's King in checkmate!

      Let's get started

    HEREDOC
  end
end
