class King
  attr_reader :color, :unicode, :captured
  UNICODE = "\u265A"

  def initialize(color, unicode = "\u265A")
    color == 1 ? @color = unicode.colorize(:light_yellow) : @color = unicode.colorize(:cyan)
    @unicode = unicode
    @captured = false
  end

  def move(board, player_color, start_row, dest_row, column)
    board[dest_row][column] = board[start_row][column]
    board[start_row][column] = ' '
  end

  def allowed_move?(start_row, dest_row, player_color)
    if player_color == UNICODE.colorize(:light_yellow)
      (start_row - dest_row).abs.between?(1, 2) && dest_row < start_row
    else
      (start_row - dest_row).abs.between?(1, 2) && dest_row > start_row
    end
  end
end