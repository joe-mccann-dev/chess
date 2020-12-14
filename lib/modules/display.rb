# frozen_string_literal: true

# controls display of Board and various puts methods
module Display
  WHITE = "\u265F".colorize(:light_yellow).freeze
  BLACK = "\u265F".colorize(:cyan).freeze

  def display(starting_row = 8)
    puts `clear` unless @self_in_check
    print_captured_white_pieces
    @squares.each_with_index do |row, index|
      print "  #{starting_row} "
      index.even? ? print_even_row(row) : print_odd_row(row)
      starting_row -= 1
      puts "\n"
    end
    print "     a  b  c  d  e  f  g  h\n\n"
    print_captured_black_pieces
  end

  def print_captured_white_pieces
    @captured_by_black.each { |piece| print "  #{piece.displayed_color}" } if @captured_by_black.any?
    puts "\n\n"
  end

  def print_captured_black_pieces
    @captured_by_white.each { |piece| print "  #{piece.displayed_color}" } if @captured_by_white.any?
    puts
  end

  def print_even_row(row)
    row.each_with_index do |square, col_index|
      col_index.even? ? print_on_light_black(square) : print_on_black(square)
    end
  end

  def print_odd_row(row)
    row.each_with_index do |square, col_index|
      col_index.even? ? print_on_black(square) : print_on_light_black(square)
    end
  end

  def print_on_light_black(square)
    print '   '.on_light_black if square.is_a?(EmptySquare)
    return if square.is_a?(EmptySquare)

    if square == @active_piece
      print " #{square.displayed_color} ".on_magenta
    else
      print " #{square.displayed_color} ".on_light_black
    end
  end

  def print_on_black(square)
    print '   '.on_black if square.is_a?(EmptySquare)
    return if square.is_a?(EmptySquare)

    if square == @active_piece
      print " #{square.displayed_color} ".on_magenta
    else
      print " #{square.displayed_color} ".on_black
    end
  end

  def announce_checkmate_or_stalemate(player, _checkmate, _stalemate)
    puts "  ** Checkmate! #{player.symbolic_color.capitalize} wins! ** ".colorize(:green) if @checkmate
    puts '  ** Stalemate. Game ends in a draw **'.colorize(:green) if @stalemate
  end

  def thanks_for_playing
    ' Thanks for playing! Have a great day!'.colorize(:green)
  end

  def show_help
    puts <<-HEREDOC
    
    #{'commands'.colorize(:green)}: #{'save'.colorize(:green)}|#{'load'.colorize(:green)}|#{'help'.colorize(:green)}|#{'quit'.colorize(:green)}|#{'resign'.colorize(:green)}|#{'draw'.colorize(:green)}

    This game uses traditional algebraic notation to enter moves.
    Attack moves must preface destination square with an #{'x'.colorize(:green)}

    #{'how to move'.colorize(:green)}:

      Every piece except the pawn is assigned a piece prefix:

      #{'King'.colorize(:green)}   => K
      #{'Queen'.colorize(:green)}  => Q
      #{'Rook'.colorize(:green)}   => R
      #{'Knight'.colorize(:green)} => N
      #{'Bishop'.colorize(:green)} => B

      #{'pawns'.colorize(:green)}      =>   e5, exd6, a5, axb6 . . .
      #{'other'.colorize(:green)}      =>   Ke7, Kxe7, Nc3, Nxc6 . . .
      #{'castling'.colorize(:green)}   =>   0-0, 0-0-0
      #{'en passant'.colorize(:green)} =>   exd6 (attack as if enemy has just moved one square)

      (moves are case sensitive)

    If disambiguation is required, you'll be prompted to choose which piece you'd like to move.

    HEREDOC
  end

  def show_ellipsis
    puts '  . . . . . '.colorize(:green)
    sleep(0.45)
  end

  def show_pawn_promotion_choices(choices, current_player)
    return if current_player.name == 'CPU'

    puts " ** pawn promotion! ** \n".colorize(:magenta)
    puts " select which piece you'd like your Pawn to become. "
    puts
    choices.each_with_index do |c, i|
      puts " enter[#{i + 1}] for #{c}".colorize(:green)
    end
  end

  def show_cpu_pawn_promotion(choices, choice, current_player)
    return unless current_player.name == 'CPU'

    puts " \n** CPU promoted its pawn to a #{choices[choice.to_i - 1]} **".colorize(:green)
    sleep(1.2)
  end

  def move_not_allowed_message(piece_type)
    " move not allowed for #{piece_type}. please try again...".colorize(:red)
  end

  def ask_for_move(player)
    puts
    puts " enter[#{'help'.colorize(:green)}] to see available commands"
    puts
    print " #{player.name} (#{player.symbolic_color.capitalize}), please enter a move: "
      .colorize(:magenta)
  end

  def ask_for_piece_number(piece_type)
    puts ' ** please select a piece to move by choosing a valid number **'.colorize(:red)
    print "#{piece_type} to move: ".colorize(:magenta)
  end
end
