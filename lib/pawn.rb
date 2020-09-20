class Pawn
  attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location

  def initialize(color, location, unicode = "\u265F")
    @num_moves = 0
    @location = location
    @captured = false
    color == 1 ? @displayed_color = unicode.colorize(:light_yellow) : @displayed_color = unicode.colorize(:cyan)
    @unicode = unicode
    @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
  end

  def assign_symbolic_color(displayed_color, unicode)
    displayed_color == unicode.colorize(:light_yellow) ? :white : :black
  end

  def allowed_move?(start_row, dest_row, player_color, start_column = nil, dest_column = nil)
    return allowed_initial_move?(start_row, dest_row, player_color, start_column, dest_column) if @num_moves == 0

    if player_color == :white
      (start_row - dest_row).abs == 1 &&
      # change once you incorporate ability for pawns to attack (column abs diff can be 1)
      (start_column - dest_column).abs == 0 && 
      dest_row < start_row
    else
      (start_row - dest_row).abs == 1 && 
        dest_row > start_row &&
        (start_column - dest_column).abs == 0
    end
  end

  def allowed_initial_move?(start_row, dest_row, player_color, start_column = nil, dest_column = nil)
    if player_color == :white
      (start_row - dest_row).abs.between?(1, 2) &&
      # change once you incorporate ability for pawns to attack (column abs diff can be 1)
        (start_column - dest_column).abs == 0 &&
        dest_row < start_row
    else
      (start_row - dest_row).abs.between?(1, 2) && 
        dest_row > start_row &&
        (start_column - dest_column).abs == 0
    end
  end

  def update_num_moves
    @num_moves += 1
  end

  def update_location(dest_row, column)
    @location = [dest_row, column]
    puts "new location: #{@location}"
  end
end