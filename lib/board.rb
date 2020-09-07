# frozen_string_literal: true

require 'colorize'

class Board
  def initialize(squares = make_initial_board)
    @squares = squares
  end

  W_ROOK = "\u265C".colorize(:light_yellow)
  W_KNIGHT = "\u265E".colorize(:light_yellow)
  W_BISHOP = "\u265D".colorize(:light_yellow)
  W_QUEEN = "\u265B".colorize(:light_yellow)
  W_KING = "\u265A".colorize(:light_yellow)
  W_PAWN = "\u265F".colorize(:light_yellow)
  EMPTY = ' '
  B_ROOK = "\u265C".colorize(:cyan)
  B_KNIGHT = "\u265E".colorize(:cyan)
  B_BISHOP = "\u265D".colorize(:cyan)
  B_QUEEN = "\u265B".colorize(:cyan)
  B_KING = "\u265A".colorize(:cyan)
  B_PAWN = "\u265F".colorize(:cyan)

  def make_initial_board
    @squares = [
      [B_ROOK, B_KNIGHT, B_BISHOP, B_QUEEN, B_KING, B_BISHOP, B_KNIGHT, B_ROOK],
      [B_PAWN, B_PAWN, B_PAWN, B_PAWN, B_PAWN, B_PAWN, B_PAWN, B_PAWN],
      [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY],
      [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY],
      [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY],
      [EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY, EMPTY],
      [W_PAWN, W_PAWN, W_PAWN, W_PAWN, W_PAWN, W_PAWN, W_PAWN, W_PAWN],
      [W_ROOK, W_KNIGHT, W_BISHOP, W_QUEEN, W_KING, W_BISHOP, W_KNIGHT, W_ROOK]
    ]
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
      if col_index.even?
        print " #{square} ".on_light_black
      else
        print " #{square} ".on_black
      end
    end
  end

  def print_odd_row(row)
    row.each_with_index do |square, col_index|
      if col_index.even?
        print " #{square} ".on_black
      else
        print " #{square} ".on_light_black
      end
    end
  end
end
