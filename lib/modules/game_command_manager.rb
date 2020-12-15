# frozen_string_literal: true

# handles non-move commands
module GameCommandManager
  def manage_other_commands(command)
    # #save_game and #load_game located in Serializer
    save_game         if command.match?(/save/)
    load_game         if command.match?(/load/)
    show_help         if command.match?(/help/)
    exit_game         if command.match?(/quit/)
    resign_match      if command.match?(/resign/)
    request_draw      if command.match?(/draw/)
    handle_board_flip if command.match?(/flip/)
  end

  def non_move_command?(input)
    input.match?(/save|load|help|quit|resign|draw|flip/)
  end

  # if flip command has been entered, @board.flipped is not true until @board.display_flipped is called
  # therefore, if board has been flipped, entering "flip" again means you want to display original board state
  def handle_board_flip
    @board.flipped ? @board.display : @board.display_flipped
  end

  def exit_game
    puts thanks_for_playing
    exit
  end

  def resign_match
    @resigned = true
    winner = opposite_player(@current_player  )
    puts " ** #{@current_player.name} resigns. #{winner.name} wins! **"
    puts thanks_for_playing
  end

  def request_draw
    return draw_requested_against_cpu if @cpu_mode

    other_player = opposite_player(@current_player)
    puts draw_offer_message(other_player)
    response = gets.chomp
    loop do
      break if response.match?(/Y|y|N|n/)
      puts 'please enter Y or N'

      response = gets.chomp
    end
    @draw = response.match?(/Y|y/)
    after_draw_request_message(@draw)
  end

  def draw_requested_against_cpu
    puts
    puts ' ** Draw declined! You can beat this CPU!! ** '.colorize(:red)

    return
  end

  def after_draw_request_message(draw_accepted)
    if draw_accepted
      puts ' ** Game ends in a draw **'.colorize(:green)
      puts thanks_for_playing
    else
      puts ' ** Draw declined ** '.colorize(:red)
    end
  end

  def opposite_player(current_player)
    current_player == @player1 ? @player2 : @player1
  end
end
