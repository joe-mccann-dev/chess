# frozen_string_literal: true

module Display
  
  WHITE = "\u265F".colorize(:light_yellow).freeze
  BLACK = "\u265F".colorize(:cyan).freeze

  def show_welcome_message
    puts <<-HEREDOC

      Welcome to Chess

      Win by placing your opponent's King in checkmate!

      Let's get started

    HEREDOC
  end

  def display(starting_row = 8)
    puts
    @squares.each_with_index do |row, index|
      print "\t#{starting_row} "
      index.even? ? print_even_row(row) : print_odd_row(row)
      starting_row -= 1
      puts "\n"
    end
    print "\t   a   b   c   d   e   f   g   h\n\n"
  end

  def display_captured
    print "\n captured by white: "
    @captured_by_white.each { |piece| print "#{piece.displayed_color} "}
    print "\n captured by black: "
    @captured_by_black.each { |piece| print "#{piece.displayed_color} "}
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
    print " #{square}  ".on_light_black if square == ' '
    unless square == ' '
      print " #{square.displayed_color}  ".on_light_black
    end
  end

  def print_on_black(square)
    print " #{square}  ".on_black if square == ' '
    unless square == ' '
      print " #{square.displayed_color}  ".on_black
    end
  end
end
