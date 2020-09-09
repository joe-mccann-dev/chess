# frozen_string_literal: true

require 'colorize'
require './modules/display.rb'

class Board
  include Display

  def initialize(squares = make_initial_board)
    @squares = squares
  end

  def make_initial_board
    @squares = [
      black_row,
      Array.new(8) { Pawn.new(2, "\u265F") },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { Pawn.new(1, "\u265F") },
      white_row
    ]
  end

  def white_row
    [
      Rook.new(1, "\u265C"), Knight.new(1, "\u265E"), Bishop.new(1, "\u265D"),
      Queen.new(1, "\u265B"), King.new(1, "\u265A"),
      Bishop.new(1, "\u265D"), Knight.new(1, "\u265E"), Rook.new(1, "\u265C")
    ]
  end

  def black_row
    [
      Rook.new(2, "\u265C"), Knight.new(2, "\u265E"), Bishop.new(2, "\u265D"),
      Queen.new(2, "\u265B"), King.new(2, "\u265A"),
      Bishop.new(2, "\u265D"), Knight.new(2, "\u265E"), Rook.new(2, "\u265C")
    ]
  end

  def update_board(move)
    # if piece is a pawn
    move = move.split('')
    column = letter_index(move[0])
    row = move[1].to_i
    @squares.reverse[row - 1][column] = "\u265F".colorize(:light_yellow)
    @squares.reverse[1][column] = ' '
  end

  def letter_index(letter)
    ('a'..'h').select.each_with_index { |_x, index| index }.index(letter)
  end
end
