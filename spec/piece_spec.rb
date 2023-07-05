require_relative 'require_helper.rb'

describe Piece do
  describe '#allowed_move?' do

    context 'when piece is a pawn' do

      let(:pawn_at_start) { Pawn.new(1, [6, 4])}
      subject(:pawn) { pawn_at_start }
      context 'move is allowed' do
        it 'returns true' do
          dest_row = 4
          dest_col = 4
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'move is not allowed' do
        it 'returns false' do
          dest_row = 3
          dest_col = 4
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end

      context 'when pawn tries to move one space backwards' do
        
        let(:pawn_in_middle) { Pawn.new(1, [4, 4])} 
        subject(:pawn) { pawn_in_middle }
        
        it 'returns false' do
          dest_row = 5
          dest_col = 4
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end

      context 'when a pawn tries an attack move when attacking is inappropriate' do
        let(:pawn_at_start) { Pawn.new(1, [6, 4])} 
        subject(:pawn) { pawn_at_start }
        
        it 'returns false' do
          dest_row = 5
          dest_col = 5
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end

      context 'when a pawn tries an attack move on an enemy one diagonal away' do
        
        let(:pawn_at_start) { Pawn.new(1, [6, 4])}
        subject(:pawn) { pawn_at_start }

        before do
          start_row = 6
          start_col = 4
          dest_row = 5
          dest_column = 5
          pawn.instance_variable_set(:@attack_mode, true)
        end

        it 'returns true' do
          dest_row = 5
          dest_col = 5
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'when a pawn tries an attack move on an enemy two diagonals away' do

        let(:pawn_in_middle) { Pawn.new(1, [6, 4]) }
        subject(:pawn) { pawn_in_middle }

        before do
          start_row = 6
          start_col = 4
          dest_row = 4
          dest_column = 5
          pawn.instance_variable_set(:@attack_mode, true)
        end

        it 'returns false' do
          dest_row = 4
          dest_col = 5
          result = pawn.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end
    end

    context 'when piece is a knight' do
      let(:knight_at_starting_row) { Knight.new(1, [7, 6]) }
      subject(:knight) { knight_at_starting_row }

      context 'move is allowed' do
        it 'returns true' do
          dest_row = 5
          dest_col = 5
          result = knight.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'move is not allowed' do
        it 'returns false' do
          dest_row = 4
          dest_col = 4
          result = knight.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end
    end

    context 'when piece is a bishop' do

      let(:bishop_at_starting_row) { Bishop.new(1, [7, 2]) }
      subject(:bishop) { bishop_at_starting_row}
      
      context 'move is allowed' do
        it 'returns true' do
          dest_row = 5
          dest_col = 0
          result = bishop.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'move is not allowed' do
        it 'returns false' do
          dest_row = 5
          dest_col = 2
          result = bishop.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end
    end

    context 'when piece is a queen' do
      let(:queen_in_middle) { Queen.new(1, [4, 4]) }

      subject(:queen) { queen_in_middle}

      context 'move is allowed' do
        it 'returns true' do
          dest_row = 4
          dest_col = 7
          result = queen.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'move is not allowed' do
        it 'returns false' do
          dest_row = 5
          dest_col = 7
          result = queen.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end
    end

    context 'when piece is a king' do


      let(:king_in_middle) { King.new(1, [4, 4])}
      subject(:king) { king_in_middle }

      context 'move is allowed' do
        it 'returns true' do
          dest_row = 3
          dest_col = 5
          result = king.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'move is not allowed' do
        it 'returns false' do
          dest_row = 6
          dest_col = 4
          result = king.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end
    end

    context 'when piece is a rook' do

      let(:rook_in_middle) { Rook.new(1, [4, 4]) }
      subject(:rook) { rook_in_middle }

      context 'move is allowed' do
        it 'returns true' do
          dest_row = 7
          dest_col = 4
          result = rook.allowed_move?(dest_row, dest_col)
          expect(result).to be(true)
        end
      end

      context 'move is not allowed' do
        it 'returns true' do
          dest_row = 7
          dest_col = 7
          result = rook.allowed_move?(dest_row, dest_col)
          expect(result).to be(false)
        end
      end
    end
  end
end