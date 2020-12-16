class Piece
    include AdjacencyListGenerator
    attr_reader :displayed_color, :symbolic_color, :unicode, :captured, :location, :prefix
  
    def initialize(color, location, unicode = '')
      @captured = false
      @location = location
      @displayed_color = color == 1 ? unicode.colorize(:light_yellow) : unicode.colorize(:cyan)
      @unicode = unicode
      @symbolic_color = assign_symbolic_color(@displayed_color, @unicode)
      @prefix = ''
    end
  
    def assign_symbolic_color(displayed_color, unicode)
      displayed_color == unicode.colorize(:light_yellow) ? :white : :black
    end
  
    def allowed_move?(dest_row, dest_column)
      available_squares.include?([dest_row, dest_column])
    end
  
    def update_location(dest_row, dest_column)
      @location = [dest_row, dest_column]
    end
  
    def mark_as_captured
      @captured = true
    end
  end