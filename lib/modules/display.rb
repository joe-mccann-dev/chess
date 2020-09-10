module Display
  def display(starting_row = 8)
    puts
    @squares.each_with_index do |row, index|
      print "#{starting_row} "
      index.even? ? print_even_row(row) : print_odd_row(row)
      starting_row -= 1
      puts "\n"
    end
    print "   a  b  c  d  e  f  g  h\n\n"
  end

  def print_even_row(row)
    row.each_with_index do |square, col_index|
      col_index.even? ? print_on_light_black(square) : print_on_black(square)
    end
  end

  def print_odd_row(row)
    row.each_with_index do |square, col_index|
      col_index.even? ? print_on_black(square) : print_on_light_black(square)
    end
  end

  def print_on_light_black(square)
    print " #{square} ".on_light_black       if     square.is_a?(String)
    print " #{square.color} ".on_light_black unless square.is_a?(String)
  end

  def print_on_black(square)
    print " #{square} ".on_black       if     square.is_a?(String)
    print " #{square.color} ".on_black unless square.is_a?(String)
  end
end