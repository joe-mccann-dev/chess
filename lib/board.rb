# frozen_string_literal: true

require 'colorize'

class Board
  def initialize(squares = make_initial_board)
    @squares = squares
  end

  W_ROOK = "\u2656".colorize(:black)
  W_KNIGHT = "\u2658".colorize(:black)
  W_BISHOP = "\u2657".colorize(:black)
  W_QUEEN = "\u2655".colorize(:black)
  W_KING = "\u2654".colorize(:black)
  W_PAWN = "\u2659".colorize(:black)
  EMPTY = ' '
  B_ROOK = "\u265C".colorize(:black)
  B_KNIGHT = "\u265E".colorize(:black)
  B_BISHOP = "\u265D".colorize(:black)
  B_QUEEN = "\u265B".colorize(:black)
  B_KING = "\u265A".colorize(:black)
  B_PAWN = "\u265F".colorize(:black)

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

  def display
    @squares.each_with_index do |row, index|
      index.even? ? print_even_row(row) : print_odd_row(row)
      puts "\n"
    end
    nil
  end

  def print_even_row(row)
    row.each_with_index do |square, i|
      if i.even?
        print " #{square} ".on_white
      else
        print " #{square} ".on_blue
      end
    end
  end

  def print_odd_row(row)
    row.each_with_index do |square, i|
      if i.even?
        print " #{square} ".on_blue
      else
        print " #{square} ".on_white
      end
    end
  end
end
