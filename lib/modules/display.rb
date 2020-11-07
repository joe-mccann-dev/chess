# frozen_string_literal: true

module Display
  
  WHITE = "\u265F".colorize(:light_yellow).freeze
  BLACK = "\u265F".colorize(:cyan).freeze

  def show_welcome_message
    puts <<-HEREDOC

  Welcome to Chess!

    Win by placing your opponent's King in checkmate.

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
