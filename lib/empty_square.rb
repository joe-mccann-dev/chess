class EmptySquare
    attr_reader :location, :symbolic_color

    def initialize(location)
      @location = location
      @symbolic_color = nil
    end
  end