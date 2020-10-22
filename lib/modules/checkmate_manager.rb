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

  def check_if_move_results_in_check(player_color)
    reassign_relevant_board_variables(player_color)
    mark_king_as_in_check?(player_color)
  end

  def mark_king_as_in_check?(player_color)
    if player_color == :white
      @black_king_in_check = white_puts_black_in_check?(player_color)
      puts 'black in check' if @black_king_in_check
    else
      @white_king_in_check = black_puts_white_in_check?(player_color)
      puts 'white in check' if @white_king_in_check
    end
    @target.mark_as_in_check if @black_king_in_check || @white_king_in_check
  end

  def check_if_players_own_move_puts_them_in_check(player_color)
    opposite_color = player_color == :white ? :black : :white
    reassign_relevant_board_variables(opposite_color)
    check_if_move_results_in_check(opposite_color)
  end

  def reassign_relevant_board_variables(player_color)
    if player_color == :white
      @dest_row = black_king.location[0]
      @dest_column = black_king.location[1]
    else
      @dest_row = white_king.location[0]
      @dest_column = white_king.location[1]
    end
    @checking_for_check = true
    @target = @squares[@dest_row][@dest_column]
    @attack_move = true
  end

  def white_puts_black_in_check?(player_color)
    white_pieces.any? do |piece|
      attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece)
    end
  end

  def black_puts_white_in_check?(player_color)
    black_pieces.any? do |piece|
      attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece)
    end
  end
end 