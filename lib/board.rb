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
      Array.new(8) { Pawn.new(2) },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { ' ' },
      Array.new(8) { Pawn.new(1) },
      white_row
    ]
  end

  def white_row
    [
      Rook.new(1), Knight.new(1), Bishop.new(1),
      Queen.new(1), King.new(1),
      Bishop.new(1), Knight.new(1), Rook.new(1)
    ]
  end

  def black_row
    [
      Rook.new(2), Knight.new(2), Bishop.new(2),
      Queen.new(2), King.new(2),
      Bishop.new(2), Knight.new(2), Rook.new(2)
    ]
  end

  def white_pieces(pieces = [])
    @squares.each do |row|
      row.each do |square|
        unless square == ' '
          pieces << square if square.color == square.unicode.colorize(:light_yellow)
        end
      end
    end
    pieces
  end

  def black_pieces(pieces = [])
    @squares.each do |row|
      row.each do |square|
        unless square == ' '
          pieces << square if square.color == square.unicode.colorize(:cyan)
        end
      end
    end
    pieces
  end

  def update_board(move)
    move = move.split('')
    # if piece.is_a?(Pawn)
      column = letter_index(move[0])
      row = move[1].to_i
      
      @squares.reverse[row - 1][column] = "\u265F".colorize(:light_yellow)
      @squares.reverse[1][column] = ' '
      piece_in_column?(column)
    # end
  end

  def piece_in_column?(column)
    col_members = []
    0.upto(7) { |row| col_members << @squares[row][column] }
    col_members
  end

  def letter_index(letter)
    ('a'..'h').select.each_with_index { |_x, index| index }.index(letter)
  end

  def valid_move?(input)
    input = input.split('')
    input[0].downcase.match?(/[a-h]/) && input[1].match?(/[1-8]/)
  end
end
