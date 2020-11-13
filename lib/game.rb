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
    @board.display
    show_welcome_message
    print " first player's name: ".colorize(:magenta)
    @player1.request_name
    print "\n other player's name: ".colorize(:magenta)
    @player2.request_name
    @player1.request_color
    assign_color(@player1.displayed_color)
  end

  def assign_color(color)
    color == WHITE ? @player2.assign_color(2) : @player2.assign_color(1)
  end

  def play_game
    @board.display
    @player1.symbolic_color == :white ? player1_goes_first : player2_goes_first
  end

  def player1_goes_first
    loop do
      break if @checkmate
      
      player1_turn
      break if @checkmate

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
    update_and_display_board(player1_move, @player1.symbolic_color)
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
    update_and_display_board(player2_move, @player2.symbolic_color)
  end

  def update_and_display_board(move, player_color)
    @board.update_board(move, player_color)
    if @board.pawn_promotable?(@board.found_piece, player_color)
      @board.prompt_for_pawn_promotion(player_color)
      bug_preventing_placeholder = Board.new(@board.duplicate_board(@board.squares))
      determine_check_status(player_color, bug_preventing_placeholder)
    end
    @board.display
    announce_check(player_color, @duplicate)
  end

  def move_follows_rules?(move, player_color)
    # @opponent_in_check will be true when next player attempts a castle move
    return false if @board.castle_move && @opponent_in_check

    @duplicate = Board.new(@board.duplicate_board(@board.squares))
    simulate_and_examine_board_state(move, player_color, @duplicate)
    determine_check_status(player_color, @duplicate)
    announce_check(player_color, @duplicate)
    follows_rules = !@self_in_check && basic_conditions_met?(player_color, @board)
    @board.mark_target_as_captured(follows_rules)
    follows_rules
  end

  def determine_check_status(player_color, board)
    @opponent_in_check = board.move_puts_player_in_check?(player_color)
    check_for_checkmate(player_color, board) if @opponent_in_check
    puts "@checkmate: #{@checkmate}"
    @self_in_check = board.move_puts_self_in_check?(player_color)
  end
  
  def check_for_checkmate(player_color, board)
    king_moves = board.king_moves_in_algebraic_notation(player_color)
    unsuccessful_escape_count = count_moves_that_result_in_check(player_color, king_moves)
    @checkmate = unsuccessful_escape_count == king_moves.length && 
      !board.check_blockable?(player_color)
  end

  def count_moves_that_result_in_check(player_color, king_moves)
    count = 0
    king_moves.each do |move|
      # duplicate board for every potential move.
      duplicate = Board.new(@duplicate.duplicate_board(@duplicate.squares))
      opposite_color = player_color == :white ? :black : :white
      simulate_and_examine_board_state(move, opposite_color, duplicate)
      escape_attempt_puts_in_check = duplicate.move_puts_self_in_check?(opposite_color)
      count += 1 if escape_attempt_puts_in_check
    end
    count
  end

  # reassigns target variables to duplicate, then updates duplicate in order to verify move doesn't
  # put player's own king in check
  def simulate_and_examine_board_state(move, player_color, duplicate)
    duplicate.assign_piece_type(move)
    duplicate.assign_target_variables(move, player_color)
    return false unless basic_conditions_met?(player_color, duplicate)
    
    duplicate.re_ambiguate
    duplicate.update_board(move, player_color)
  end

  def basic_conditions_met?(player_color, board)
    board.piece_found &&
    board.valid_move?(board.start_row, board.start_column, player_color, board.found_piece)
  end

  def announce_check(player_color, duplicate)
    puts "\n  ** #{duplicate.opposite(player_color).capitalize} in check! **".colorize(:red) if @opponent_in_check && 
      !@self_in_check
    puts "\n ** that move leaves #{player_color.capitalize} in check! **".colorize(:magenta) if @self_in_check
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
    puts
    print " #{@player1.name} (#{@player1.symbolic_color.capitalize}), please enter a move: "
      .colorize(:magenta)
    gets.chomp
  end

  def request_player2_move
    puts
    print " #{@player2.name} (#{@player2.symbolic_color.capitalize}), please enter a move: "
      .colorize(:magenta)
    gets.chomp
  end
end
