# frozen_string_literal: true

# verifies input at every move
module InputValidator
  def valid_input?(input)
    return manage_other_commands(input) if non_move_command?(input)
    return valid_castle_move?(input) if input.include?('0')
    return false unless input.length.between?(2, 4)

    if input.length == 4
      valid_attack_move?(input) || valid_pawn_attack?(input)
    elsif input.length == 2
      valid_pawn_move?(input)
    else
      valid_character_move?(input)
    end
  end

  def valid_attack_move?(move)
    move[0].match?(/R|N|B|Q|K/) &&
      move[1].match?('x') &&
      move[2].match?(/[a-h]/) &&
      move[3].match?(/[1-8]/)
  end

  def valid_pawn_attack?(move)
    move[0].match?(/[a-h]/) &&
      move[1].match?('x') &&
      move[2].match?(/[a-h]/) &&
      move[3].match?(/[1-8]/)
  end

  def valid_pawn_move?(move)
    move[0].match?(/[a-h]/) &&
      move[1].match?(/[1-8]/)
  end

  def valid_character_move?(move)
    move[0].match?(/R|N|B|Q|K/) &&
      move[1].match?(/[a-h]/) &&
      move[2].match?(/[1-8]/)
  end

  def valid_castle_move?(move)
    move.length == 3 ? move.match?(/0-0/) : move.match?(/0-0-0/)
  end
end
