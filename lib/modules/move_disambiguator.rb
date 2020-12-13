module MoveDisambiguator
  def disambiguate_if_necessary(pieces, piece_type, disambiguated)
    if pieces.length > 1
      decide_which_piece_to_move(pieces, piece_type, disambiguated)
    else
      @@disambiguated = false
      assign_start_location(pieces[0]) unless pieces.empty?
      @piece_found = true
      pieces[0]
    end
  end

  # d/t way code is structured,
  # (@duplicate) in Game, this method gets called twice
  # when checking for check, thereby prompting the user a second time unnecessarily.
  # the use of @@disambiguated prevents this from happening.
  def decide_which_piece_to_move(pieces, piece_type, disambiguated)
    unless disambiguated || cpu_move_requires_disambiguation?(pieces)
      request_disambiguation(pieces, piece_type)
      response = gets.chomp.to_i
    end
    # prevents a nil error when disambiguate_move gets called
    # prevent getting prompted when cpu selects a move that requires disambiguation
    response = 1 if disambiguated || cpu_move_requires_disambiguation?(pieces)
    loop do
      break if response.between?(1, pieces.length)

      puts ' ** please select a piece to move by choosing a valid number **'.colorize(:red)
      print "#{piece_type} to move: ".colorize(:magenta)
      request_disambiguation(pieces, piece_type)
      response = gets.chomp.to_i
    end
    @@disambiguated = true
    disambiguate_move(response, pieces)
  end

  def cpu_move_requires_disambiguation?(pieces)
    (@cpu_mode && @cpu_color == pieces[0].symbolic_color)
  end

  def request_disambiguation(pieces, piece_type)
    coordinates = []
    puts
    puts " ** #{pieces.length} #{piece_type}s can go to that location ** \n".colorize(:green)
    pieces.each_with_index do |piece, index|
      row = translate_row_index_to_displayed_row(piece.location[0])
      col = translate_col_index_to_displayed_col(piece.location[1])
      coordinates << "#{col}#{row}"
      puts " enter[#{index + 1}] to move the #{piece_type} at #{coordinates[index]}".colorize(:green)
    end
    print " #{piece_type} to move: ".colorize(:magenta)
  end

  def translate_row_index_to_displayed_row(row)
    chess_rows = [8, 7, 6, 5, 4, 3, 2, 1]
    chess_rows[row]
  end

  def translate_col_index_to_displayed_col(column_index)
    ('a'..'h').each_with_index { |l, i| return l if i == column_index }
  end

  def disambiguate_move(response, pieces)
    assign_start_location(pieces[response - 1])
    @piece_found = true
    pieces[response - 1]
  end
end
