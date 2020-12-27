# frozen_string_literal: true

# creates and assigns board variables relevant to a desired move
module SetupBoardVariables
  CHESS_ROWS = [8, 7, 6, 5, 4, 3, 2, 1].freeze
  CHESS_COLUMNS = %w[a b c d e f g h].freeze
  PREFIXES = ['', 'R', 'N', 'B', 'Q', 'K'].freeze

  def assign_piece_type(move)
    @piece_prefix = assign_prefix(move)
    @piece_type = determine_piece_class(@piece_prefix)
    @piece_type = King if valid_castle_move?(move)
  end

  def assign_prefix(move)
    if move.length == 2 || valid_pawn_attack?(move)
      ''
    else
      move[0].upcase
    end
  end

  def determine_piece_class(prefix, piece_objects = [Pawn, Rook, Knight, Bishop, Queen, King].freeze)
    PREFIXES.each_with_index do |pre, index|
      return piece_objects[index] if pre == prefix
    end
  end

  def assign_target_variables(move, player_color)
    return assign_castle_targets(move, player_color) if valid_castle_move?(move)

    @checking_for_check = false
    @castle_move = false
    @en_passant = false
    enable_or_disable_attack_rules(move)
    @dest_row = find_dest_row(move)
    @dest_column = determine_dest_column(move)
    @target = @squares[@dest_row][@dest_column]
    @en_passant = true if @target.is_a?(EmptySquare) && valid_pawn_attack?(move)
    @found_piece = find_piece(move, player_color, @piece_type)
  end

  def enable_or_disable_attack_rules(move)
    @attack_move = move.length == 4
  end

  def assign_start_location(piece)
    @start_row = piece.location[0]
    @start_column = piece.location[1]
  end

  def find_dest_row(move)
    # regular pawn move
    if move.length == 2
      CHESS_ROWS.index(move[1].to_i)
    # regular character move
    elsif move.length == 3
      CHESS_ROWS.index(move[2].to_i)
    # attack move (character = Bxe5, pawn = exd5)
    else
      CHESS_ROWS.index(move[3].to_i)
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
    CHESS_COLUMNS.select.each_with_index { |_x, index| index }.index(letter)
  end
end
