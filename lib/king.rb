class King
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured

  def initialize(color, unicode = "\u265A")
    @captured = false
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
  end

  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
  end

  def allowed_move?(start_row, dest_row, column, player_color)
    (start_row - dest_row).abs == 1
  end
end