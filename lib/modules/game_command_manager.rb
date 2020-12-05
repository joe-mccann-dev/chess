# frozen_string_literal: true

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
    puts "#{@current_player.name} resigns. #{winner.name} wins!"
    puts thanks_for_playing
  end

  def request_draw
    @draw = true
    puts " Game ends in a draw".colorize(:green)
    puts thanks_for_playing
  end

  def thanks_for_playing
    " Thanks for playing! Have a great day!".colorize(:green)
  end

  def show_help
    puts <<-HEREDOC
    
    available commands: save|load|help|quit|resign|draw

    Quick Start Guide:

    This game uses traditional algebraic notation to enter moves.

    Each piece, except the Pawn, is assigned a piece prefix:
    King, Queen, Rook, Knight, Bishop = K, Q, R, N, B

      Move examples:

        Pawns: e5, exd6, a5, axb6, etc . . .
        Main Pieces: Ke7, Kxe7, Nc3, Nxc6, etc . . .
        Castles: 0-0, 0-0-0
    
    Moves are case sensitive.
    If more than one piece can go to a location, you'll be prompted to select one.

    HEREDOC
  end
end