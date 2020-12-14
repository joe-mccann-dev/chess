# frozen_string_literal: true

# handles non-move commands
module GameCommandManager
  def manage_other_commands(command)
    # #save_game and #load_game located in Serializer
    save_game    if command.match?(/save/)
    load_game    if command.match?(/load/)
    show_help    if command.match?(/help/)
    exit_game    if command.match?(/quit/)
    resign_match if command.match?(/resign/)
    request_draw if command.match?(/draw/)
  end

  def non_move_command?(input)
    input.match?(/save|load|help|quit|resign|draw/)
  end

  def exit_game
    puts thanks_for_playing
    exit
  end

  def resign_match
    @resigned = true
    winner = @current_player == @player1 ? @player2 : @player1
    puts " ** #{@current_player.name} resigns. #{winner.name} wins! **"
    puts thanks_for_playing
  end

  def request_draw
    @draw = true
    puts ' ** Game ends in a draw **'.colorize(:green)
    puts thanks_for_playing
  end
end
