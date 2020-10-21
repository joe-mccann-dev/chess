# frozen_string_literal: true

module SetupBoardVariables
  def assign_piece_type(move)
    @piece_prefix = assign_prefix(move)
    @piece_type = determine_piece_class(@piece_prefix)
    @piece_type = King if valid_castle_move?(move)
  end

  def handle_castle_move(move)
    
  end

  def assign_prefix(move)
    if move.length == 2 || valid_pawn_attack?(move)
      ''
    else
      move[0].upcase
    end
  end

  def determine_piece_class(prefix)
    piece_objects = [Pawn, Rook, Knight, Bishop, Queen, King]
    prefixes = ['', 'R', 'N', 'B', 'Q', 'K']
    prefixes.each_with_index do |p, index|
      return piece_objects[index] if p == prefix
    end
  end

  def assign_target_variables(move, player_color)
    return assign_castle_targets(move, player_color) if valid_castle_move?(move)

    @castle_move = false
    enable_or_disable_attack_rules(move)
    @dest_row = find_dest_row(move)
    @dest_column = determine_dest_column(move)
    @target = @squares[@dest_row][@dest_column]
    @found_piece = find_piece(move, player_color, @piece_type)
  end

  def assign_castle_targets(move, player_color)
    @castle_move = true
    @attack_move = false
    @dest_row = player_color == :white ? 7 : 0
    @dest_column = move.length == 3 ? 6 : 2
    assign_relevant_rook(move, player_color)
    @target = @squares[@dest_row][@dest_column]
    @found_piece = find_piece(move, player_color, @piece_type)
  end

  def assign_relevant_rook(move, player_color)
    # king side castle
    if move.length == 3
      @relevant_rook = @squares[7][7] if player_color == :white
      @relevant_rook = @squares[0][7] if player_color == :black
    # queen side castle
    else
      @relevant_rook = @squares[7, 0] if player_color == :white
      @relevant_rook = @squares[0][0] if player_color == :black
    end
  end

  def enable_or_disable_attack_rules(move)
    @attack_move = move.length == 4
  end

  def assign_start_location(piece)
    @start_row = piece.location[0]
    @start_column = piece.location[1]
  end

  def find_dest_row(move)
    chess_rows = [8, 7, 6, 5, 4, 3, 2, 1]
    # regular pawn move
    if move.length == 2
      chess_rows.index(move[1].to_i)
    # regular character move
    elsif move.length == 3
      chess_rows.index(move[2].to_i)
    # attack move (character = Bxe5, pawn = exd5)
    else
      chess_rows.index(move[3].to_i)
    end
  end

  def determine_dest_column(move)
    if move.length == 2
      translate_letter_to_index(move[0].downcase)
    elsif move.length == 3
      translate_letter_to_index(move[1].downcase)
    else 
      translate_letter_to_index(move[2].downcase)
    end
  end

  def translate_letter_to_index(letter)
    ('a'..'h').select.each_with_index { |_x, index| index }.index(letter)
  end
end