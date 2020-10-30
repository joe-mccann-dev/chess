# frozen_string_literal: true

module CheckmateManager
  def check?
    white_king.in_check || black_king.in_check
  end

  def white_king
   white_pieces.select { |piece| piece.is_a?(King) }[0]
  end

  def black_king
    black_pieces.select { |piece| piece.is_a?(King) }[0]
  end

  def mark_king_as_in_check?(player_color)
    if player_color == :white
      @black_king_in_check = white_puts_black_in_check?(player_color)
      puts 'black in check' if @black_king_in_check
      @target.mark_as_in_check if @black_king_in_check
    else
      @white_king_in_check = black_puts_white_in_check?(player_color)
      puts 'white in check' if @white_king_in_check
      @target.mark_as_in_check if @white_king_in_check
    end
  end

  def move_puts_player_in_check?(player_color)
    reassign_relevant_board_variables(player_color)
    # mark_king_as_in_check?(player_color)
  end

  def move_puts_self_in_check?(player_color)
    opposite_color = player_color == :white ? :black : :white
    reassign_relevant_board_variables(opposite_color)
    # mark_king_as_in_check?(opposite_color)
  end

  def reassign_relevant_board_variables(player_color)
    @checking_for_check = true
    @attack_move = true
    if player_color == :white
      target = black_king
      white_puts_black_in_check?(player_color, target)
    else
      target = white_king
      black_puts_white_in_check?(player_color, target)
    end
  end

  def white_puts_black_in_check?(player_color, target)
    white_pieces.any? do |piece|
      attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece, target)
    end
  end

  def black_puts_white_in_check?(player_color, target)
    black_pieces.any? do |piece|
      attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece, target)
    end
  end
end 