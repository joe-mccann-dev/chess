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
    print " player1's name: ".colorize(:magenta) unless @player2.name == 'CPU'
    print " Please enter your name: ".colorize(:magenta) if @player2.name == 'CPU'
    
    @player1.request_name
    print "\n player2's name: ".colorize(:magenta) unless @player2.name == 'CPU'
    @player2.request_name
    @player1.request_color
    assign_color(@player1.displayed_color)
  end

  def assign_color(color)
    color == WHITE ? @player2.assign_color(2) : @player2.assign_color(1)
  end

  def play_game
    @board.display
    # maintains turn order when resuming a loaded game
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

      @current_player = @player1
      player_turn(@current_player)
      announce_checkmate_or_stalemate(@player1, @checkmate, @stalemate)
      break if game_over?

      @current_player = @player2
      @cpu_mode ? cpu_turn : player_turn(@current_player)
      announce_checkmate_or_stalemate(@player2, @checkmate, @stalemate)
    end
    puts thanks_for_playing
  end

  def player2_goes_first
    loop do
      break if game_over?

      @current_player = @player2
      @cpu_mode ? cpu_turn : player_turn(@current_player)
      announce_checkmate_or_stalemate(@player2, @checkmate, @stalemate)
      break if game_over?

      @current_player = @player1
      player_turn(@current_player)
      announce_checkmate_or_stalemate(@player1, @checkmate, @stalemate)
    end
    puts thanks_for_playing
  end

  def game_over?
    @stalemate || @checkmate || @resigned || @draw
  end

  def player_turn(current_player)
    validate_move_assign_piece_type(current_player)
    loop do
      assign_board_target_variables(@move, current_player.symbolic_color)
      break if move_follows_rules?(@move, current_player.symbolic_color)

      puts move_not_allowed_message(@board.piece_type)
      validate_move_assign_piece_type(current_player)
    end
    update_and_display_board(@move, current_player.symbolic_color)
    determine_check_status(current_player.symbolic_color, @board, @board.found_piece)
  end

  def cpu_turn
    generate_available_cpu_moves
    validate_move_assign_piece_type(@player2)
    show_ellipsis
    loop do
      assign_board_target_variables(@move, @player2.symbolic_color)
      break if move_follows_rules?(@move, @player2.symbolic_color)

      find_valid_cpu_move
      assign_board_piece_type(@move)
    end
    update_and_display_board(@move, @player2.symbolic_color)
    determine_check_status(@player2.symbolic_color, @board, @board.found_piece)
  end

  def validate_move_assign_piece_type(current_player)
    @move = current_player.name == 'CPU' ? obtain_random_cpu_move : validate_player_move(current_player)
    assign_board_piece_type(@move)
  end

  def find_valid_cpu_move
    @move = @board.cpu_moves.pop
    @move = generate_random_cpu_move if @move.nil?
  end

  # loop breaks if input string is valid algebraic notation
  def validate_player_move(player)
    move = request_player_move(player)
    loop do
      break if valid_input?(move)

      puts ' invalid input. enter help for available commands'.colorize(:red) unless non_move_command?(move)
      move = request_player_move(player)
    end
    move
  end

  # used for when cpu_move turns up nil
  def generate_random_cpu_move
    @board.generate_cpu_moves(@player2.symbolic_color)[(rand * @board.cpu_moves.length).floor]
  end

  # create initial list of cpu_moves prior to its turn
  def generate_available_cpu_moves
    @board.generate_cpu_moves(@player2.symbolic_color)
  end

  # gets a random move from list generated above (rather than regenerate the list each time)
  def obtain_random_cpu_move
    @board.cpu_moves[(rand * @board.cpu_moves.length).floor]
  end

  def assign_board_piece_type(move)
    @board.assign_piece_type(move)
  end

  def assign_board_target_variables(move, player_color)
    @board.assign_target_variables(move, player_color)
  end

  def update_and_display_board(move, player_color)
    @board.update_board(move, player_color)
    evaluate_board_for_pawn_promotion(player_color)
    @board.display
    announce_check(player_color, @duplicate)
  end

  def evaluate_board_for_pawn_promotion(player_color)
    return unless @board.pawn_promotable?(@board.found_piece, player_color)

    @board.prompt_for_pawn_promotion(player_color, @current_player)
    # necessary to accurately determine check status after a pawn is promoted
    placeholder = Board.new(@board.duplicate_board(@board.squares))
    determine_check_status(player_color, placeholder, @board.found_piece)
  end

  def move_follows_rules?(move, player_color)
    # @opponent_in_check will be true when next player attempts a castle move
    return false if @board.castle_move && @opponent_in_check

    @duplicate = Board.new(@board.duplicate_board(@board.squares))
    # duplicate current board, then make the move, regardless of check
    simulate_and_examine_board_state(move, player_color, @duplicate)
    # see if that move results in check, checkmate, or stalemate
    @piece_found_and_valid_move = piece_found_and_valid_move?(player_color, @board)
    determine_check_status(player_color, @duplicate, @duplicate.found_piece)
    # move doesn't follow rules if it puts your king in check
    announce_check(player_color, @duplicate)
    @follows_rules = !@self_in_check && @piece_found_and_valid_move
    @board.mark_target_as_captured(@follows_rules)
    @follows_rules
  end

  def determine_check_status(player_color, board, found_piece)
    @opponent_in_check = board.other_player_in_check?(player_color, @piece_found_and_valid_move)
    @self_in_check = board.self_in_check?(player_color, @piece_found_and_valid_move)
    @stalemate = stalemate?(player_color, board, found_piece)
    @checkmate = checkmate?(player_color, board, found_piece)
  end

  def checkmate?(player_color, board, found_piece)
    board.other_player_in_check?(player_color, @piece_found_and_valid_move) &&
      rules_common_to_stalemate_and_checkmate?(player_color, board, found_piece)
  end

  def stalemate?(player_color, board, found_piece)
    !board.other_player_in_check?(player_color, @piece_found_and_valid_move) &&
      board.no_legal_moves?(player_color) &&
      rules_common_to_stalemate_and_checkmate?(player_color, board, found_piece)
  end

  def rules_common_to_stalemate_and_checkmate?(player_color, board, found_piece)
    return if found_piece.nil?
    
    board.turn_attack_move_on
    row = found_piece.location[0]
    col = found_piece.location[1]
    if !board.attack_rules_followed?(row, col, player_color, found_piece, board.opponent_king(player_color))
      found_piece = find_revealed_attacker_piece(row, col, player_color, found_piece, board)
    end
    
    every_king_move_results_in_check?(player_color, board) &&
      !board.can_block_or_capture?(player_color, found_piece)
  end

  # necessary for when the active piece doesn't threaten king
  # but moves out of the way of a piece that does threaten king,
  # and that line of attack results in a check
  # in that case, find the piece that CAN attack the king and 
  # use it to determine if board.can_block_or_capture?
  def find_revealed_attacker_piece(row, col, player_color, found_piece, board)
    board.current_player_pieces(player_color).each do |piece|
      piece_row = piece.location[0]
      piece_col = piece.location[1]
      opponent_king = board.opponent_king(player_color)
      return piece if board.attack_rules_followed?(piece_row, piece_col, player_color, piece, opponent_king)

    end
    # ensure a piece (not an array) is returned
    found_piece
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
    return false unless piece_found_and_valid_move?(player_color, duplicate)

    duplicate.re_ambiguate
    duplicate.update_board(move, player_color)
  end

  def piece_found_and_valid_move?(player_color, board)
    board.piece_found &&
      board.valid_move?(board.start_row, board.start_column, player_color, board.found_piece)
  end

  def announce_check(player_color, duplicate)
    puts "\n  ** #{duplicate.opposite(player_color).capitalize} in check! **".colorize(:red) if @opponent_in_check &&
                                                                                                !@self_in_check && 
                                                                                                @follows_rules
    # prevent spamming of message as cpu cycles thru random moves
    return if @cpu_mode && @current_player == @player2

    puts "\n ** that move leaves #{player_color.capitalize} in check! **".colorize(:red) if @self_in_check
  end

  def request_player_move(player)
    exit if game_over?
    puts
    print " #{player.name} (#{player.symbolic_color.capitalize}), please enter a move: "
      .colorize(:magenta)
    gets.chomp
  end
end
