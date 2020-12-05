# frozen_string_literal: true

module Display
  
  WHITE = "\u265F".colorize(:light_yellow).freeze
  BLACK = "\u265F".colorize(:cyan).freeze

  def show_help
    puts <<-HEREDOC

    This game uses traditional algebraic notation to enter moves.
    Moves are case sensitive.

    Pawns:

      Regular pawn move: "e5"
        To move a pawn, enter its file (column) in lower case, followed by the rank (row) to which you want to move it.
        To move from e2 to e4, for example, then you would simply enter 'e4'
    
      Pawn attack move: "exd5"
        To attack with a pawn, enter its file followed by an 'x' and the rank and file of the piece that you wish to attack.
        To attack the piece at d5, enter 'exd5'
    
    All other pieces: "Qh5", "Qxh5", "Ke7", "Nxc3", etc.

      Each piece is assigned a piece prefix:
      
        King   = K
        Queen  = Q
        Rook   = R
        Knight = N
        Bishop = B
      
      Regular move:
        In uppercase, type the piece prefix of the piece you'd like to move, followed by the desired file and rank.
        To move your Queen to h5, for example, then you would enter 'Qh5' and so on for the other pieces.

      Attack move:
        Similar to above, but preface your destination file and rank with a lowercase 'x'.
        For example, if there is an opponent piece at h5 and you wish to attack it with your Queen,
        enter 'Qxh5'

    Special moves:

      Castling: 
        To King-side castle, enter '0-0'
        To Queen-side castle, enter '0-0-0'

      En Passant:
        Perform the attack as if you are attacking the empty square behind the pawn eligible for an en passant attack
        For example, your pawn is at e5, opponent pawn is at d5.
        enter 'exd6' to capture the opponent pawn at d5
        

    HEREDOC
  end

  def display(starting_row = 8)
    puts `clear` if !@self_in_check
    print_captured_white_pieces
    @squares.each_with_index do |row, index|
      print "  #{starting_row} "
      index.even? ? print_even_row(row) : print_odd_row(row)
      starting_row -= 1
      puts "\n"
    end
    print "     a   b   c   d   e   f   g   h\n\n"
    print_captured_black_pieces
  end

  def print_captured_white_pieces
    if @captured_by_black.any?
      @captured_by_black.each { |piece| print "  #{piece.displayed_color}"}
    end
    puts "\n\n"
  end

  def print_captured_black_pieces
    if @captured_by_white.any?
      @captured_by_white.each { |piece| print "  #{piece.displayed_color}"}
    end
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
    print "    ".on_light_black if square.is_a?(EmptySquare)
    unless square.is_a?(EmptySquare)
      if square == @active_piece 
        print " #{square.displayed_color}  ".on_white
      else
        print " #{square.displayed_color}  ".on_light_black
      end
    end
  end

  def print_on_black(square)
    print "    ".on_black if square.is_a?(EmptySquare)
    unless square.is_a?(EmptySquare)
      if square == @active_piece 
        print " #{square.displayed_color}  ".on_white
      else
        print " #{square.displayed_color}  ".on_black
      end
    end
  end
end
