class EmptySquare
    attr_reader :location, :symbolic_color

    def initialize(location, symbolic_color = nil)
      @location = location
      @symbolic_color = symbolic_color
    end
  end