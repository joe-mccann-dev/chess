# frozen_string_literal: true

# handles non-move commands
module GameCommandManager
  def manage_other_commands(command)
    options = %i[save_game load_game show_help quit_game resign_match request_draw flip_board]
    options.each { |option| return send(option) if option.to_s.match?(command) }
  end

  def non_move_command?(input)
    input.match?(/^save$|^load$|^help$|^quit$|^resign$|^draw$|^flip$/)
  end

  # if flip command has been entered, @board.flipped is not true until @board.display_flipped is called
  # therefore, if board has been flipped, entering "flip" again means you want to display original board state
  def flip_board
    @board.flipped ? @board.display : @board.display_flipped
  end

  def quit_game
    puts thanks_for_playing
    exit
  end

  def resign_match
    @resigned = true
    winner = opposite_player(@current_player)
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

      print 'please enter Y or N: '

      response = gets.chomp
    end
    @draw = response.match?(/Y|y/)
    after_draw_request_message(@draw)
  end

  def draw_requested_against_cpu
    puts
    puts ' ** Draw declined! You can beat this CPU!! ** '.colorize(:red)
    # return
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
