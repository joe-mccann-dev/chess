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
    if player_color == :white
      @black_king_in_check = white_pieces.any? do |piece|
        attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece)
      end
      puts 'black in check' if @black_king_in_check
    else
      @white_king_in_check = black_pieces.any? do |piece|
        attack_rules_followed?(piece.location[0], piece.location[1], player_color, piece)
      end
      puts 'white in check' if @white_king_in_check
    end
    @target.mark_as_in_check if @black_king_in_check || @white_king_in_check
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

  # def move_puts_player_in_check?(piece, player_color)
  #   if player_color == :black
  #     piece.update_location(@dest_row, @dest_column)
  #     result = white_pieces.any? { |piece| attack_rules_followed?(piece.location[0], piece.location[1], :black, black_king) }
  #   end
  #   piece.update_location(@start_row, @start_column)
  #   result
  # end
end 