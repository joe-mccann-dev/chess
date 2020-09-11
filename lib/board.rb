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

  def update_board(move, player_color, piece = nil)
    column = letter_index(move[0])
    origin_row_index = find_starting_index(column, player_color)
    dest_row_index = find_destination_index(move)
    pawn = @squares[origin_row_index][column]
    pawn.move(@squares, player_color, origin_row_index, dest_row_index, column)
  end

  def find_starting_index(column, player_color)
    0.upto(7) do |row|
      if @squares[row][column].is_a?(Pawn) && @squares[row][column].color == player_color
        return row
      end
    end
  end

  def find_destination_index(move)
    chess_rows = [8, 7, 6, 5, 4, 3, 2, 1]
    chess_rows.index(move[1].to_i)
  end

  def letter_index(letter)
    ('a'..'h').select.each_with_index { |_x, index| index }.index(letter)
  end

  def valid_move?(input)
    input = input.split('')
    input[0].downcase.match?(/[a-h]/) && input[1].match?(/[1-8]/)
  end
end
