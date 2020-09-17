class Bishop
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location

  def initialize(color, location, unicode = "\u265D")
    @captured = false
    @location = location
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
  end

  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
  end

  def allowed_move?(start_row, dest_row, player_color)
    if player_color == :white
      (start_row - dest_row).abs.between?(1, 2) && dest_row < start_row
    else
      (start_row - dest_row).abs.between?(1, 2) && dest_row > start_row
    end
  end

  def update_location(dest_row, column)
    @location = [dest_row, column]
    p @location
  end
end