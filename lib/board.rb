require 'colorize'

class Board
  def initialize(squares = nil)
    @squares = make_initial_board
  end


  W_ROOK = "\u2656".colorize(:black)
  W_KNIGHT = "\u2658".colorize(:black)
  W_BISHOP = "\u2657".colorize(:black)
  W_QUEEN = "\u2655".colorize(:black)
  W_KING = "\u2654".colorize(:black)
  W_PAWN = "\u2659".colorize(:black)

  W_SQUARE = "  ".on_yellow
  B_SQUARE = "  ".on_green

  B_ROOK = "\u265C".colorize(:black)
  B_KNIGHT = "\u265E".colorize(:black)
  B_BISHOP = "\u265D".colorize(:black)
  B_QUEEN = "\u265B".colorize(:black)
  B_KING = "\u265A".colorize(:black)
  B_PAWN = "\u265F".colorize(:black)

  def make_initial_board
    @squares = [
      [B_ROOK,   B_KNIGHT, B_BISHOP, B_QUEEN,  B_KING,   B_BISHOP, B_KNIGHT, B_ROOK  ],
      [B_PAWN,   B_PAWN,   B_PAWN,   B_PAWN,   B_PAWN,   B_PAWN,   B_PAWN,   B_PAWN  ],
      [W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE],
      [B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE],
      [W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE],
      [B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE, B_SQUARE, W_SQUARE],
      [W_PAWN,   W_PAWN,   W_PAWN,   W_PAWN,   W_PAWN,   W_PAWN,   W_PAWN,   W_PAWN  ],
      [W_ROOK,   W_KNIGHT, W_BISHOP, W_QUEEN,  W_KING,   W_BISHOP, W_KNIGHT, W_ROOK  ],
    ]
  end

  def display
    8.times do |i|
      if i.even?
        4.times do |n| 
          print W_SQUARE
          print B_SQUARE
        end
        puts "\n"
      else
        4.times do |n|
          print B_SQUARE
          print W_SQUARE
        end
        puts "\n"
      end
    end
  end
end