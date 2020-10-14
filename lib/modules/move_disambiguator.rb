 module MoveDisambiguator
  def count_pieces(pieces, piece_type)
    if pieces.length > 1
      decide_which_piece_to_move(pieces, piece_type)
    else
      assign_start_location(pieces[0]) unless pieces.empty?
      @piece_found = true
      pieces[0]
    end
  end

  def decide_which_piece_to_move(pieces, piece_type)
    request_disambiguation(pieces, piece_type)
    response = gets.chomp.to_i
    loop do
      break if response.between?(1, 2)

      puts '** Please enter 1 or 2 **'
      request_disambiguation(pieces, piece_type)
      response = gets.chomp.to_i
    end
    disambiguate_move(response, pieces)
  end

  def request_disambiguation(pieces, piece_type)
    piece_one_col = translate_column_index(pieces[0].location[1], pieces)
    piece_two_col = translate_column_index(pieces[1].location[1], pieces)
    puts "** Two #{piece_type.to_s}s can go to that location **"
    puts "which piece would you like to move," +
    " the #{piece_type} at column #{piece_one_col}" + 
    " or the #{piece_type} at column #{piece_two_col}?"
    print "enter 1 for #{piece_one_col} or enter 2 for #{piece_two_col}: "
  end

  def translate_column_index(column_index, pieces)
    ('a'..'h').each_with_index { |l, i| return l if i == column_index }
  end

  def disambiguate_move(response, pieces)
    assign_start_location(pieces[response - 1])
    @piece_found = true
    pieces[response - 1]
  end
end
