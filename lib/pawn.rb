class Pawn
  attr_reader :color, :unicode, :captured

  def initialize(color, unicode = "\u265F")
    color == 1 ? @color = unicode.colorize(:light_yellow) : @color = unicode.colorize(:cyan)
    @unicode = unicode
    @captured = false
  end

  def move(board, player_color, start_index, dest_index, column)
    if valid?(start_index, dest_index, player_color)
      board[dest_index][column] = board[start_index][column]
      board[start_index][column] = ' '
    else
      puts 'wrong'
    end
  end

  def valid?(start_index, dest_index, player_color)
    if player_color == unicode.colorize(:light_yellow)
      (start_index - dest_index).abs.between?(1, 2) && dest_index < start_index
    else
      (start_index - dest_index).abs.between?(1, 2) && dest_index > start_index
    end
  end
end