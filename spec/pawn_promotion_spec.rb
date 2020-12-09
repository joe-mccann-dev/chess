require 'colorize'
require_relative '../lib/modules/display'
require_relative '../lib/modules/setup_board_variables'
require_relative '../lib/modules/adjacency_list_generator'
require_relative '../lib/modules/input_validator'
require_relative '../lib/modules/move_validator'
require_relative '../lib/modules/move_disambiguator'
require_relative '../lib/modules/castle_manager'
require_relative '../lib/modules/checkmate_manager'
require_relative '../lib/modules/pawn_promotion'
require_relative '../lib/modules/cpu_move_generator'
require_relative '../lib/board'
require_relative '../lib/empty_square.rb'
require_relative '../lib/player'
require_relative '../lib/rook'
require_relative '../lib/knight'
require_relative '../lib/bishop'
require_relative '../lib/king'
require_relative '../lib/queen'
require_relative '../lib/pawn'

describe PawnPromoter do
  describe '#pawn_promotable?' do
    let(:player_color) { :white }

    context 'when a pawn reaches its final possible row' do
      let(:white_pawn_at_zeroth_row) { instance_double(Pawn, is_a?: Pawn, symbolic_color: :white, location: [0, 0]) }
      
      let(:board_state_with_promotable_pawn) {[
        Array.new(8) { |c| c == 0 ? white_pawn_at_zeroth_row : EmptySquare.new([0, c]) },
        # other board squares irrelevant to this method
      ]}

      subject(:board) { Board.new(board_state_with_promotable_pawn) }

      it 'returns true' do
        result = board.pawn_promotable?(white_pawn_at_zeroth_row, player_color)
        expect(result).to be(true)  
      end
    end

    context 'when a pawn is not on the final possible row' do
      let(:white_pawn_at_first_row) { instance_double(Pawn, is_a?: Pawn, symbolic_color: :white, location: [1, 0]) }
      
      let(:board_state_with_non_promotable_pawn) {[
        Array.new(8) { |c| c == 0 ? white_pawn_at_first_row : EmptySquare.new([1, c]) },
        # other board squares irrelevant to this method
      ]}

      subject(:board) { Board.new(board_state_with_non_promotable_pawn) }

      it 'returns false' do
        result = board.pawn_promotable?(white_pawn_at_first_row, player_color)
        expect(result).to be(false)  
      end
    end

  end

  describe '#promote_pawn' do
    let(:player_color) { :white }

    context 'after a promotion choice has been made' do

      let(:move) { 'a8'}
      # player chooses a queen
      let(:choice_number) { 1 } 
      let(:pawn_about_to_be_promoted) { instance_double(Pawn, symbolic_color: :white, location: [0, 0]) }
      let(:pawn_at_final_row) {[
          Array.new(8) { |c| c == 0 ? pawn_about_to_be_promoted : EmptySquare.new([0, c]) }
          # other board squares irrelevant to this method
      ]}
      
      subject(:board_with_promotable_pawn) { Board.new(pawn_at_final_row)}

      before do
        board_with_promotable_pawn.assign_target_variables(move, player_color)
      end

      it 'updates the destination square to be the chosen piece type' do
        promoted = board_with_promotable_pawn.promote_pawn(choice_number, player_color)
        selected_piece_class = Queen
        promoted_class = promoted.class
        expect(selected_piece_class).to eq(promoted_class)
      end
    end
  end
end