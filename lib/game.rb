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
    @board.prompt_for_pawn_promotion(player_color) if @board.pawn_promotable?(@board.found_piece, player_color)
    @board.display
    announce_check(player_color, @duplicate)
  end

  def move_follows_rules?(move, player_color)
    # @opponent_in_check will be true when next player attempts a castle move
    return false if @board.castle_move && @opponent_in_check

    @duplicate = Board.new(@board.duplicate_board(@board.squares))
    simulate_and_examine_board_state(move, player_color, @duplicate)
    @opponent_in_check = @duplicate.move_puts_player_in_check?(player_color)
    if @opponent_in_check
      @piece_that_put_opp_in_check = @duplicate.found_piece
      # binding.pry
      if player_color == :white
        
        # move = all the squares that the black king can move to legally
        # need to translate, e.g. [0, 1] to a "move", such as "Kb8", 
        # and then pass it into simulate_and_examine_board_state
        # do this within a loop?
        # every time a move results in move_puts_self_in_check? returning true
        # increase count by 1
        # if count equals number of king_moves => checkmate
        king_moves = @duplicate.black_king.available_squares
        # @duplicate.assign_start_location(@duplicate.black_king)
        algebraic_notations = []
        king_moves.each do |square_location|
          row = @duplicate.translate_row_index_to_displayed_row(square_location[0])
          col = @duplicate.translate_column_index(square_location[1])
          if @duplicate.squares[square_location[0]][square_location[1]].symbolic_color == player_color
            # include in x since attack mode should be on to simulate king attacking its way out of check
            algebraic_notations << "Kx#{col}#{row}"
          else
            algebraic_notations << "K#{col}#{row}"
          end
        end
        count = 0
        algebraic_notations.each do |move|
          # binding.pry
          duplicate = Board.new(@duplicate.duplicate_board(@duplicate.squares))
          opposite_color = player_color == :white ? :black : :white
          simulate_and_examine_board_state(move, opposite_color, duplicate)
          escape_puts_in_check = duplicate.move_puts_self_in_check?(opposite_color)
          count += 1 if escape_puts_in_check
        end
      end
      # checkmate is true if every space the king can go to results in a check
      pieces_minus_king = @duplicate.black_pieces.select { |p| !p.is_a?(King) }
      @checkmate = count == king_moves.length && 
      pieces_minus_king.none? do |piece|
        # only works when attacker attacks from same row or column??
        put_in_check_via_row = @duplicate.black_king.location[0] == @piece_that_put_opp_in_check.location[0]
        put_in_check_via_col = @duplicate.black_king.location[1] == @piece_that_put_opp_in_check.location[1]
        attacker_row = @piece_that_put_opp_in_check.location[0]
        attacker_col = @piece_that_put_opp_in_check.location[1]
        # if put_in_check_via_row
          col = @duplicate.black_king.location[1] + 1
          row = @duplicate.black_king.location[0]
          while col < attacker_col
            binding.pry
            attacker_col = @piece_that_put_opp_in_check.location[1]
            result = @duplicate.regular_move_rules_followed?(piece.location[0], piece.location[1], :black, piece, @duplicate.squares[row][col])
            break if result

            col += 1
          end
        # end
        result
      end
      puts "@checkmate: #{@checkmate}"
    end
      # duplicate board for every potential move (found in king.available_squares)
      # if all those moves result in king putting himself in check,
      # then checkmate == true
    @self_in_check = @duplicate.move_puts_self_in_check?(player_color)
    king = @duplicate.black_king
    
    puts "self in check: #{@self_in_check}"
    puts "opponent in check: #{@opponent_in_check}"
    announce_check(player_color, @duplicate)
    follows_rules = !@self_in_check && basic_conditions_met?(player_color, @board)
    @board.mark_target_as_captured(follows_rules)
    follows_rules
  end

      # @test = @opponent_in_check && 
    # @duplicate.attack_rules_followed?(king.location[0], king.location[1], :black, king, @duplicate.squares[king.available_squares[1][0]][king.available_squares[1][1]])
    # puts "test result: #{@test}"

  # reassigns target variables to duplicate, then updates duplicate in order to verify move doesn't
  # put player's own king in check
  def simulate_and_examine_board_state(move, player_color, duplicate)
    duplicate.assign_piece_type(move)
    duplicate.assign_target_variables(move, player_color)
    return false unless basic_conditions_met?(player_color, duplicate)
    
    duplicate.re_ambiguate
    duplicate.update_board(move, player_color)
  end

  def basic_conditions_met?(player_color, board_object)
    board_object.piece_found &&
    board_object.valid_move?(board_object.start_row, board_object.start_column, player_color, board_object.found_piece)
  end

  def announce_check(player_color, duplicate)
    opposite_color = player_color == :white ? :black : :white
    puts "\n  ** #{opposite_color.capitalize} in check! **".colorize(:red) if @opponent_in_check && 
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
