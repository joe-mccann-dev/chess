# frozen_string_literal: true

module InputValidator
  def valid_input?(move)
    return false unless move.length.between?(2, 4)

    if move.length == 4
      valid_attack_move?(move) || valid_pawn_attack?(move)
    elsif move.length == 2
      valid_pawn_move?(move)
    else
      valid_character_move?(move)
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
end