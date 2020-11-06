# frozen_string_literal: true

class Board
  include Display
  include MoveValidator
  include InputValidator
  include SetupBoardVariables
  include CastleManager
  include CheckmateManager
  include MoveDisambiguator
  attr_reader :start_row, :start_column, :dest_row, :dest_column, :squares, :found_piece, :piece_type, :piece_found, :castle_move

  def initialize(squares = make_initial_board)
    @squares = squares
    @captured_by_white = []
    @captured_by_black = []
  end

  def make_initial_board
    @squares = [
      black_row,
      Array.new(8) { |c| Pawn.new(2, [1, c]) },
      Array.new(8) { |c| EmptySquare.new([2, c]) },
      Array.new(8) { |c| EmptySquare.new([3, c]) },
      Array.new(8) { |c| EmptySquare.new([4, c]) },
      Array.new(8) { |c| EmptySquare.new([5, c]) },
      Array.new(8) { |c| Pawn.new(1, [6, c]) },
      white_row
    ]
  end

  def duplicate_board(squares)
    board = Array.new(8) { Array.new }
    squares.each_with_index do |row, row_idx|
      row.each_with_index do |square, col_idx|
        if square.is_a?(EmptySquare)
          board[row_idx] << EmptySquare.new([row_idx, col_idx])
        else
          square.symbolic_color == :white ? color_arg = 1 : color_arg = 2
          board[row_idx] << square.class.new(color_arg, [row_idx, col_idx])
        end
      end
    end
    board
  end


  def black_row
    [
      Rook.new(2, [0, 0]), Knight.new(2, [0, 1]), Bishop.new(2, [0, 2]),
      Queen.new(2, [0, 3]), King.new(2, [0, 4]),
      Bishop.new(2, [0, 5]), Knight.new(2, [0, 6]), Rook.new(2, [0, 7])
    ]
  end

  def white_row
    [
      Rook.new(1, [7, 0]), Knight.new(1, [7, 1]), Bishop.new(1, [7, 2]),
      Queen.new(1, [7, 3]), King.new(1, [7, 4]),
      Bishop.new(1, [7, 5]), Knight.new(1, [7, 6]), Rook.new(1, [7, 7])
    ]
  end

  def white_pieces(white_pieces = [])
    @squares.each do |row|
      row.each do |square|
        unless square.is_a?(EmptySquare)
          white_pieces << square if square.symbolic_color == :white
        end
      end
    end
    white_pieces
  end

  def black_pieces(black_pieces = [])
    @squares.each do |row|
      row.each do |square|
        unless square.is_a?(EmptySquare)
          black_pieces << square if square.symbolic_color == :black
        end
      end
    end
    black_pieces
  end

  def push_captured_pieces
    black_pieces.each { |piece| @captured_by_white << piece if piece.captured }
    white_pieces.each { |piece| @captured_by_black << piece if piece.captured }
  end

  def find_piece(move, player_color, piece_type)
    @piece_found = false
    return castle_white_or_black_king(player_color) if valid_castle_move?(move)

    player_color == :white ? find_white_piece(move, piece_type) : find_black_piece(move, piece_type)
  end

  def find_white_piece(move, piece_type)
    pieces = white_pieces_that_go_to_dest.select { |piece| piece.is_a?(piece_type) }
    valid_pawn_attack?(move) ? find_attack_pawn(pieces, move) : count_pieces(pieces, piece_type)
  end

  def find_black_piece(move, piece_type)
    pieces = black_pieces_that_go_to_dest.select { |piece| piece.is_a?(piece_type) }
    valid_pawn_attack?(move) ? find_attack_pawn(pieces, move) : count_pieces(pieces, piece_type)
  end

  # prevents unnecessary disambiguation since all pawn attacks indicate starting column
  # and are therefore not ambiguous moves
  def find_attack_pawn(pieces, move)
    attacking_pawn = pieces.select do |p|
      # attacking pawn is the one residing in specified column (the first character entered)
      p.is_a?(Pawn) && p.location[1] == translate_letter_to_index(move[0])
    end[0]
    assign_start_location(attacking_pawn) if attacking_pawn
    @piece_found = true
    attacking_pawn
  end

  def white_pieces_that_go_to_dest
    white_pieces.select { |piece| valid_move?(piece.location[0], piece.location[1], :white, piece) }
  end

  def black_pieces_that_go_to_dest
    black_pieces.select { |piece| valid_move?(piece.location[0], piece.location[1], :black, piece) }
  end

  def update_board(move, player_color)
    push_captured_pieces
    # move piece to new square
    @squares[@dest_row][@dest_column] = @squares[@start_row][@start_column]
    handle_en_passant_move(player_color)
    # move piece to new square in the same column. make previous location an empty string
    @squares[@start_row][@dest_column]  = EmptySquare.new([@start_row, @dest_column]) if @start_column == @dest_column
    # move piece to new square in a different column. make previous location an empty string
    @squares[@start_row][@start_column] = EmptySquare.new([@start_row, @start_column]) if @start_column != @dest_column
    @found_piece.update_num_moves if num_moves_relevant?(@found_piece)
    @found_piece.update_location(@dest_row, @dest_column)
    reposition_rook(move) if @castle_move
    # sets an active_piece for en_passant conditions after location is updated
    @active_piece = @found_piece
  end

  def pawn_promotable?(piece, player_color)
    return unless piece.is_a?(Pawn)

    player_color == :white ? piece.location[0] == 0 : piece.location[0] == 7
  end

  def prompt_for_pawn_promotion(player_color)
    puts "\n Pawn promotion! Select which piece you'd like your pawn to become. ".colorize(:yellow)
    print " Enter [1] for Queen, [2] for Rook, [3] for Knight, [4] for Bishop: ".colorize(:yellow)
    choice = gets.chomp.to_i
    choice = 1 unless choice.between?(1, 4)
    promote_pawn(choice, player_color)
  end

  def promote_pawn(choice, player_color)
    choices = [Queen, Rook, Knight, Bishop]
    if player_color == :white
      @squares[@dest_row][@dest_column] = choices[choice - 1].new(1, [@dest_row, @dest_column] )
    else
      @squares[@dest_row][@dest_column] = choices[choice - 1].new(2, [@dest_row, @dest_column] )
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

  def num_moves_relevant?(found_piece)
    found_piece.is_a?(Pawn) || found_piece.is_a?(King) || found_piece.is_a?(Rook)
  end

  def mark_target_as_captured(move_followed_rules)
    if move_followed_rules
      @target.mark_as_captured unless @target.is_a?(EmptySquare)
    end
  end
end
