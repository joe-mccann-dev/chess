# frozen_string_literal: false

require 'yaml'

# saves or loads a game by serializing board and player objects
module Serializer
  def save_game
    Dir.mkdir 'saved_games' unless Dir.exist? 'saved_games'
    filename = "#{verify_filename}.yaml"
    File.open("saved_games/#{filename}", 'w') { |file| file.write save_to_yaml }
    puts "#{filename} saved in chess/saved_games"
  end

  def verify_filename
    print "please enter a filename for your game: "
    filename = gets.chomp.strip
    loop do
      break if filename.match?(/\w/)

      puts 'please only enter letters, digits, or underscores'
      filename = gets.chomp.strip
    end
    filename
  end

  def save_to_yaml
    YAML.dump(
      'board' => @board,
      'player1' => @player1,
      'player2' => @player2,
      'current_player' => @current_player,
      'cpu_mode' => @cpu_mode
    )
  end

  def load_game
    yaml_files = File.join('**', '*.yaml')
    saved_games = Dir.glob(yaml_files, base: 'saved_games')
    if saved_games.empty?
      puts 'no games found!'
      return
    end

    saved_games.each_with_index { |game, index| puts "[#{index + 1}]#{game}" }
    selection = verify_selection(saved_games)
    game_file = File.open("saved_games/#{saved_games[selection - 1]}", 'r')
    extract_yaml_data(game_file)
  end

  def verify_selection(saved_games)
    print "Select a number to load a game "
    selection = gets.chomp
    loop do
      break if selection.to_i.between?(1, saved_games.length)

      puts 'please enter a valid number'
      selection = gets.chomp
    end
    selection.to_i
  end

  def extract_yaml_data(file)
    game_data = YAML.load(file)
    @board = game_data['board']
    @player1 = game_data['player1']
    @player2 = game_data['player2']
    @current_player = game_data['current_player'],
    @cpu_mode = game_data['cpu_mode']
    play_game
  end
end