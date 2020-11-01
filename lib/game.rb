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
    print " Player 1, please enter your name: ".colorize(:magenta)
    @player1.request_name
    print "\n Player 2, please enter your name: ".colorize(:magenta)
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
      break if move_follows_rules?(player1_move, @player1.symbolic_color)

      puts " move not allowed for #{@board.piece_type}. please try again...".colorize(:red)
      player1_move = validate_player1_move
    end
    @board.update_board(player1_move, @player1.symbolic_color)
    @board.display
  end

  # loop breaks if piece is found and square is available
  def player2_turn
    player2_move = validate_player2_move
    loop do
      @board.assign_target_variables(player2_move, @player2.symbolic_color)
      break if move_follows_rules?(player2_move, @player2.symbolic_color)

      puts " move not allowed for #{@board.piece_type}. please try again...".colorize(:red)
      player2_move = validate_player2_move
    end
    @board.update_board(player2_move, @player2.symbolic_color)
    @board.display
  end

  def move_follows_rules?(move, player_color)
    duplicate = Board.new(@board.duplicate_board(@board.squares))
    duplicate_board_to_prevent_move_puts_self_in_check(move, player_color, duplicate)
    duplicate.move_puts_player_in_check?(player_color)
    !duplicate.move_puts_self_in_check?(player_color) &&
    basic_conditions_met?(move, player_color, @board)
  end

  def duplicate_board_to_prevent_move_puts_self_in_check(move, player_color, duplicate)
    duplicate.assign_piece_type(move)
    duplicate.assign_target_variables(move, player_color)
    return false unless basic_conditions_met?(move, player_color, duplicate)

    duplicate.update_board(move, player_color)
  end

  def basic_conditions_met?(move, player_color, board_object)
    # binding.pry
    board_object.piece_found &&
    board_object.valid_move?(move, board_object.start_row, board_object.start_column, player_color, board_object.found_piece)
  end

  # loop breaks if input string is valid algebraic notation
  def validate_player1_move
    player1_move = request_player1_move
    loop do
      break if valid_input?(player1_move)

      puts " invalid input. please try again...".colorize(:red)
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

      puts " invalid input. please try again...".colorize(:red)
      player2_move = request_player2_move
    end
    @board.assign_piece_type(player2_move)
    player2_move
  end

  def request_player1_move
    print " #{@player1.name} (#{@player1.symbolic_color.capitalize}), please enter a move: "
      .colorize(:magenta)
    gets.chomp
  end

  def request_player2_move
    print " #{@player2.name} (#{@player2.symbolic_color.capitalize}), please enter a move: "
      .colorize(:magenta)
    gets.chomp
  end
end
