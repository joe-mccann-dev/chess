module InputValidator
  def valid_input?(move)
    return false unless move.length.between?(2, 3)

    if move.length == 2
      valid_pawn_move?(move)
    else
      valid_character_move?(move)
    end
  end

  def valid_pawn_move?(move)
    move[0].downcase.match?(/[a-h]/) &&
      move[1].match?(/[1-8]/)
  end

  def valid_character_move?(move)
    move[0].upcase.match?(/R|N|B|Q|K/) &&
      move[1].downcase.match?(/[a-h]/) &&
      move[2].match?(/[1-8]/)
  end
end