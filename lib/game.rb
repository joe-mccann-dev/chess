# frozen_string_literal: true

# handles declaration of check, checkmate, and stalemate.
# controls order of turns and saving/loading games and majority of requesting user input
class Game
  include Serializer
  include Display
  include InputValidator
  include GameCommandManager

  def initialize(board = Board.new, player1 = Player.new, player2 = Player.new)
    @player1 = player1
    @player2 = player2
    @board = board
    @cpu_mode = false
    @checkmate = false
    @stalemate = false
    @resigned = false
    @draw = false
  end

  def start_game
    @board.display
    print " first player's name: ".colorize(:magenta)
    @player1.request_name
    unless @player2.name == 'CPU'
      print "\n other player's name: ".colorize(:magenta)
      @player2.request_name
    end
    @player1.request_color
    assign_color(@player1.displayed_color)
  end

  def assign_color(color)
    color == WHITE ? @player2.assign_color(2) : @player2.assign_color(1)
  end

  def play_game
    @board.display
    return player1_goes_first if @current_player == @player1
    return player2_goes_first if @current_player == @player2

    @cpu_mode = toggle_cpu_mode(@player2)
    @board.turn_cpu_mode_on(@cpu_mode, @player2.symbolic_color)
    @player1.symbolic_color == :white ? player1_goes_first : player2_goes_first
  end

  def toggle_cpu_mode(player2)
    player2.name == 'CPU'
  end

  def player1_goes_first
    loop do
      break if game_over?

      player1_turn
      announce_checkmate_or_stalemate(@player1, @checkmate, @stalemate)
      break if game_over?

      @board.generate_cpu_moves(@player2.symbolic_color) if @cpu_mode
      player2_turn
      announce_checkmate_or_stalemate(@player2, @checkmate, @stalemate)
    end
  end

  def player2_goes_first
    loop do
      break if game_over?

      @board.generate_cpu_moves(@player2.symbolic_color) if @cpu_mode
      player2_turn
      announce_checkmate_or_stalemate(@player2, @checkmate, @stalemate)
      break if game_over?

      player1_turn
      announce_checkmate_or_stalemate(@player1, @checkmate, @stalemate)
    end
  end

  def announce_checkmate_or_stalemate(player, _checkmate, _stalemate)
    puts "  ** Checkmate! #{player.symbolic_color.capitalize} wins! ** ".colorize(:green) if @checkmate
    puts '  ** Stalemate. Game ends in a draw **'.colorize(:green) if @stalemate
  end

  # loop breaks if piece is found and square is available
  def player1_turn
    @current_player = @player1
    player1_move = validate_player_move(@player1)
    loop do
      @board.assign_target_variables(player1_move, @player1.symbolic_color)
      break if move_follows_rules?(player1_move, @player1.symbolic_color)

      puts " move not allowed for #{@board.piece_type}. please try again...".colorize(:red)
      player1_move = validate_player_move(@player1)
    end
    update_and_display_board(player1_move, @player1.symbolic_color)
    @checkmate = checkmate?(@player1.symbolic_color, @board, @board.found_piece)
  end

  # loop breaks if piece is found and square is available
  def player2_turn
    @current_player = @player2
    player2_move = @cpu_mode ? @board.cpu_moves[(rand * @board.cpu_moves.length).floor] : validate_player_move(@player2)
    @board.assign_piece_type(player2_move) if @cpu_mode
    loop do
      @board.assign_target_variables(player2_move, @player2.symbolic_color)
      break if move_follows_rules?(player2_move, @player2.symbolic_color)

      puts " move not allowed for #{@board.piece_type}. please try again...".colorize(:red) unless @cpu_mode
      player2_move = @cpu_mode ? @board.cpu_moves.pop : validate_player_move(@player2)
      # player2_move will occasionally return nil in near stalemate situations
      if player2_move.nil?
        player2_move = @board.generate_cpu_moves(@player2.symbolic_color)[(rand * @board.cpu_moves.length).floor]
      end
      @board.assign_piece_type(player2_move) if @cpu_mode
    end
    update_and_display_board(player2_move, @player2.symbolic_color)
    @checkmate = checkmate?(@player2.symbolic_color, @board, @board.found_piece)
  end

  def update_and_display_board(move, player_color)
    @board.update_board(move, player_color)
    if @board.pawn_promotable?(@board.found_piece, player_color)
      @board.prompt_for_pawn_promotion(player_color)
      # necessary to accurately determine check status after a pawn is promoted
      placeholder = Board.new(@board.duplicate_board(@board.squares))
      determine_check_status(player_color, placeholder, @board.found_piece)
    end
    @board.display
    announce_check(player_color, @duplicate)
  end

  def move_follows_rules?(move, player_color)
    # @opponent_in_check will be true when next player attempts a castle move
    return false if @board.castle_move && @opponent_in_check

    @duplicate = Board.new(@board.duplicate_board(@board.squares))
    simulate_and_examine_board_state(move, player_color, @duplicate)
    determine_check_status(player_color, @duplicate, @duplicate.found_piece)
    announce_check(player_color, @duplicate)
    follows_rules = !@self_in_check && basic_conditions_met?(player_color, @board)
    @board.mark_target_as_captured(follows_rules)
    follows_rules
  end

  def determine_check_status(player_color, board, found_piece)
    @opponent_in_check = board.move_puts_player_in_check?(player_color)
    @self_in_check = board.move_puts_self_in_check?(player_color)
    @stalemate = stalemate?(player_color, board, found_piece)
  end

  def checkmate?(player_color, board, found_piece)
    board.move_puts_player_in_check?(player_color) &&
      every_king_move_results_in_check?(player_color, board) &&
      !board.can_block_or_capture?(player_color, found_piece)
  end

  def stalemate?(player_color, board, found_piece)
    !@opponent_in_check &&
      board.no_legal_moves?(player_color) &&
      every_king_move_results_in_check?(player_color, board) &&
      !board.can_block_or_capture?(player_color, found_piece)
  end

  def every_king_move_results_in_check?(player_color, board)
    king_moves = board.king_moves_in_algebraic_notation(player_color)
    unsuccessful_escape_count = count_moves_that_result_in_check(player_color, king_moves, board)
    unsuccessful_escape_count == king_moves.length
  end

  def count_moves_that_result_in_check(player_color, king_moves, board, count = 0)
    king_moves.each do |move|
      row = board.find_dest_row(move)
      col = board.determine_dest_column(move)
      escape_attempt_puts_in_check = board.pieces_can_attack_king_moves?(row, col, player_color)
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
    # prevent spamming of message as cpu cycles thru random moves
    return if @player2.name == 'CPU'

    puts "\n ** that move leaves #{player_color.capitalize} in check! **".colorize(:magenta) if @self_in_check
  end

 # loop breaks if input string is valid algebraic notation
  def validate_player_move(player)
    move = request_player_move(player)
    loop do
      exit if game_over?
      break if valid_input?(move)
      puts " invalid input. enter help for available commands".colorize(:red) unless non_move_command?(player1_move)
      
      move = request_player_move(player)
    end
    @board.assign_piece_type(move)
    move
  end

  def request_player_move(player)
    puts
    print " #{player.name} (#{player.symbolic_color.capitalize}), please enter a move: "
      .colorize(:magenta)
    move = gets.chomp
    return manage_other_commands(move) if non_move_command?(move)

    move
  end

  def game_over?
    @stalemate || @checkmate || @resigned || @draw
  end
end
