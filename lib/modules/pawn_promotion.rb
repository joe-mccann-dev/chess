# frozen_string_literal: true

# handles pawn promotion
module PawnPromoter
  def pawn_promotable?(piece, player_color)
    return unless piece.is_a?(Pawn)

    piece.location[0] == (player_color == :white ? 0 : 7)
  end

  def prompt_for_pawn_promotion(player_color, current_player)
    choices = %w[Queen Rook Knight Bishop]
    show_pawn_promotion_choices(choices, current_player)
    choice = current_player.name == 'CPU' ? [*1..4][rand * 4] : gets.chomp
    # prevents getting prompted twice
    choice = 1 unless choice.to_i.between?(1, 4)
    show_cpu_pawn_promotion(choices, choice, current_player)
    @found_piece = promote_pawn(choice, player_color)
    @active_piece = @found_piece
  end

  def promote_pawn(choice, player_color)
    choices = [Queen, Rook, Knight, Bishop]
    @squares[@dest_row][@dest_column] = if player_color == :white
                                          choices[choice.to_i - 1].new(1, [@dest_row, @dest_column])
                                        else
                                          choices[choice.to_i - 1].new(2, [@dest_row, @dest_column])
                                        end
  end

  def handle_en_passant_move(player_color)
    attacker = @squares[@start_row][@start_column]
    return unless attacker.is_a?(Pawn) && attacker.en_passant

    if player_color == :white
      @squares[@dest_row + 1][@dest_column] = EmptySquare.new([@dest_row + 1, @dest_column])
    else
      @squares[@dest_row - 1][@dest_column] = EmptySquare.new([@dest_row - 1, @dest_column])
    end
  end
end