class Game
  include Display

  def initialize(player1 = Player.new, player2 = Player.new, board = Board.new)
    @player1 = player1
    @player2 = player2
    @board = board
    @start_column = nil
    @dest_column = nil
    @start_row = nil
    @dest_row = nil
    @piece = nil
    @piece_type = nil
    @prefix = nil
  end

  WHITE = "\u265F".colorize(:light_yellow).freeze
  BLACK = "\u265F".colorize(:cyan).freeze

  def start_game
    show_welcome_message
    print "Player 1, please enter your name: "
    @player1.request_name
    print "Player 2, please enter your name: "
    @player2.request_name
    @player1.request_color
    assign_color(@player1.displayed_color)
  end

  def play_game
    @board.display
    loop do
      player1_turn
      @board.display
      player2_turn
      @board.display
    end
  end

  def assign_color(color)
    if color == WHITE
      @player2.assign_color(2)
    else
      @player2.assign_color(1)
    end
  end

  def player1_turn
    player1_move = get_player1_move
    set_index_variables(player1_move, @player1.symbolic_color)
    @board.update_board(@start_row, @dest_row, @start_column, @dest_column, @piece)
  end

  def player2_turn
    player2_move = request_player2_move
    set_index_variables(player2_move, @player2.symbolic_color)
    @board.update_board(@start_row, @dest_row, @start_column, @dest_column, @piece)
  end

  def get_player1_move
    player1_move = request_player1_move
    loop do
      break if valid_move?(player1_move)
      
      puts 'move invalid. please select again...'
      player1_move = request_player1_move
    end
    @prefix = set_prefix(player1_move)
    @piece_type = @board.determine_piece_class(@prefix)
    player1_move
  end

  def get_player2_move
    player2_move = request_player2_move
    loop do
      break if valid_move?(player2_move)
      
      puts 'move invalid. please select again...'
      player2_move = request_player2_move
    end
    @prefix = set_prefix(player2_move)
    @piece_type = @board.determine_piece_class(@prefix)
    player2_move
  end

  def valid_move?(move)
    return false unless move.length.between?(2, 3)

    if move.length == 2
      move[0].downcase.match?(/[a-h]/) &&
        move[1].match?(/[1-8]/)
    else
      move[0].upcase.match?(/R|N|B|Q|K/) &&
        move[1].downcase.match?(/[a-h]/) &&
        move[2].match?(/[1-8]/)
    end
  end

  def break_possible?(move, dest_row, dest_column, player_color, piece_type)
    move.length.between?(2, 3) &&
      @board.find_piece(@dest_row, @dest_column, player_color, @piece_type)
  end
  
  def request_player1_move
    print "#{@player1.name} (#{@player1.symbolic_color.to_s}), please enter a move in algebraic notation: "
    gets.chomp
  end

  def request_player2_move
    print "#{@player2.name} (#{@player2.symbolic_color.to_s}), please enter a move in algebraic notation: "
    gets.chomp
  end

  def set_index_variables(move, player_color)
    @dest_row = @board.find_dest_row(move)
    @dest_column = set_dest_column(move)
    @piece = @board.find_piece(@dest_row, @dest_column, player_color, @piece_type)
    p @piece
    @start_row    = @piece.location[0] if @piece
    @start_column = @piece.location[1] if @piece
  end

  def set_prefix(move)
    if move.length == 2
      @prefix = ''
    else
      @prefix = move[0].upcase
    end
  end

  def set_dest_column(move)
    if move.length == 2
      @board.find_dest_column(move[0].downcase)
    else
      @board.find_dest_column(move[1].downcase)
    end
  end
end
