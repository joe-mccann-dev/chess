# frozen_string_literal: true

# assists in disambiguating moves, prompts player if more than one piece of same type can go to location
module MoveDisambiguator

  CHESS_ROWS = [8, 7, 6, 5, 4, 3, 2, 1].freeze
  CHESS_COLUMNS = %w[a b c d e f g h].freeze

  def disambiguate_if_necessary(pieces, piece_type, duplicate)
    if pieces.length > 1
      decide_which_piece_to_move(pieces, piece_type, duplicate)
    else
      Board.ambiguate
      assign_start_location(pieces[0]) unless pieces.empty?
      @piece_found = true
      pieces[0]
    end
  end

  def decide_which_piece_to_move(pieces, piece_type, duplicate)
    unless cpu_move_requires_disambiguation?(pieces)
      response = request_disambiguation(pieces, piece_type, duplicate)
    end
    
    # cpu simply uses first valid move
    response = 1 if cpu_move_requires_disambiguation?(pieces)
    loop do
      break if response.between?(1, pieces.length)

      puts ' ** please select a piece to move by choosing a valid number **'.colorize(:red)
      print "#{piece_type} to move: ".colorize(:magenta)
      response = request_disambiguation(pieces, piece_type, duplicate)
    end
    disambiguate_move(response, pieces)
  end

  def cpu_move_requires_disambiguation?(pieces)
    (@cpu_mode && @cpu_color == pieces[0].symbolic_color)
  end

  def request_disambiguation(pieces, piece_type, duplicate)
    return 1 if duplicate

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
    gets.chomp.to_i
  end

  def translate_row_index_to_displayed_row(row)
    CHESS_ROWS[row]
  end

  def translate_col_index_to_displayed_col(column_index)
    CHESS_COLUMNS.each_with_index { |l, i| return l if i == column_index }
  end

  def disambiguate_move(response, pieces)
    Board.disambiguate
    assign_start_location(pieces[response - 1])
    @piece_found = true
    pieces[response - 1]
  end
end
