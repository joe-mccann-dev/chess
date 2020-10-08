# frozen_string_literal: true

class Game
  include Display
  include InputValidator

  def initialize(player1 = Player.new, player2 = Player.new, board = Board.new)
    @player1 = player1
    @player2 = player2
    @board = board
  end

  def start_game
    show_welcome_message
    @board.display
    print ' Player 1, please enter your name: '
    @player1.request_name
    print "\n Player 2, please enter your name: "
    @player2.request_name
    @player1.request_color
    assign_color(@player1.displayed_color)
  end

  def assign_color(color)
    color == WHITE ? @player2.assign_color(2) : @player2.assign_color(1)
  end

  def play_game
    @board.display
    player1_chooses_white?(@player1.symbolic_color) ? player1_goes_first : player2_goes_first
  end

  def player1_chooses_white?(player1_color)
    player1_color == :white
  end

  def player1_goes_first
    loop do
      # break if @board.checkmate?
      
      player1_turn
      player2_turn
    end
  end

  def player2_goes_first
    loop do
      # break if @board.checkmate?
      player2_turn
      player1_turn
    end
  end

  # loop breaks if piece is found and square is available
  def player1_turn
    player1_move = validate_player1_move
    loop do
      @board.assign_target_variables(player1_move, @player1.symbolic_color)
      break if move_follows_rules?(@player1.symbolic_color)

      puts ' move not allowed. please try again...'
      player1_move = validate_player1_move
    end
    @board.update_board
  end

  # loop breaks if piece is found and square is available
  def player2_turn
    player2_move = validate_player2_move
    loop do
      @board.assign_target_variables(player2_move, @player2.symbolic_color)
      break if move_follows_rules?(@player2.symbolic_color)

      puts ' move not allowed. please try again...'
      player2_move = validate_player2_move
    end
    @board.update_board
  end

  def move_follows_rules?(player_color)
    @board.disambiguated || 
      @board.find_piece(player_color, @board.piece_type) &&
      @board.valid_move?(@board.start_row, @board.start_column, player_color, @board.piece)
  end

  # loop breaks if input string is valid algebraic notation
  def validate_player1_move
    player1_move = request_player1_move
    loop do
      break if valid_input?(player1_move)

      puts ' invalid input. please try again...'
      player1_move = request_player1_move
    end
    @board.assign_piece_type(player1_move)
    player1_move
  end

  # loop breaks if input string is valid algebraic notation
  def validate_player2_move
    player2_move = request_player2_move
    loop do
      break if valid_input?(player2_move)

      puts ' invalid input. please try again...'
      player2_move = request_player2_move
    end
    @board.assign_piece_type(player2_move)
    player2_move
  end

  def request_player1_move
    print " #{@player1.name} (#{@player1.symbolic_color}), please enter a move: "
    gets.chomp
  end

  def request_player2_move
    print " #{@player2.name} (#{@player2.symbolic_color}), please enter a move: "
    gets.chomp
  end
end
