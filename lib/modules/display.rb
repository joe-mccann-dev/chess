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
      print "#{starting_row} "
      index.even? ? print_even_row(row) : print_odd_row(row)
      starting_row -= 1
      puts "\n"
    end
    print "   a  b  c  d  e  f  g  h\n\n"
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
    print " #{square} ".on_light_black if square.is_a?(String)
    unless square.is_a?(String)
      print " #{square.displayed_color} ".on_light_black
    end
  end

  def print_on_black(square)
    print " #{square} ".on_black if square.is_a?(String)
    print " #{square.displayed_color} ".on_black unless square.is_a?(String)
  end
end
