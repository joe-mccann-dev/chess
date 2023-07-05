# frozen_string_literal: true

require_relative '../spec/require_helper.rb'

puts '

  ▒█░░▒█ █▀▀ █░░ █▀▀ █▀▀█ █▀▄▀█ █▀▀ 　 ▀▀█▀▀ █▀▀█
  ▒█▒█▒█ █▀▀ █░░ █░░ █░░█ █░▀░█ █▀▀ 　 ░░█░░ █░░█
  ▒█▄▀▄█ ▀▀▀ ▀▀▀ ▀▀▀ ▀▀▀▀ ▀░░░▀ ▀▀▀ 　 ░░▀░░ ▀▀▀▀

  ▄▀▄▀▄▀▄▀▄▀    ▄▀      ▄▀      ▄▀▄▀▄▀▄▀▄▀      ▄▀▄▀▄▀▄▀▄▀      ▄▀▄▀▄▀▄▀▄▀
  ▄▀            ▄▀      ▄▀      ▄▀              ▄▀              ▄▀
  ▄▀            ▄▀      ▄▀      ▄▀              ▄▀              ▄▀
  ▄▀            ▄▀      ▄▀      ▄▀              ▄▀              ▄▀
  ▄▀            ▄▀▄▀▄▀▄▀▄▀      ▄▀▄▀▄▀▄▀▄▀      ▄▀▄▀▄▀▄▀▄▀      ▄▀▄▀▄▀▄▀▄▀
  ▄▀            ▄▀      ▄▀      ▄▀                      ▄▀              ▄▀
  ▄▀            ▄▀      ▄▀      ▄▀                      ▄▀              ▄▀
  ▄▀      ▄▀    ▄▀      ▄▀      ▄▀                      ▄▀              ▄▀
  ▄▀▄▀▄▀▄▀▄▀    ▄▀      ▄▀      ▄▀▄▀▄▀▄▀▄▀      ▄▀▄▀▄▀▄▀▄▀      ▄▀▄▀▄▀▄▀▄▀

'

puts
puts ' 𝘞 𝘩𝘢𝘵 𝘸𝘰𝘶𝘭𝘥 𝘺𝘰𝘶 𝘭𝘪𝘬𝘦 𝘵𝘰 𝘥𝘰?'
puts

def player_choice
  choice = ''
  loop do
    break if choice.to_i.between?(1, 3)

    choices = ['play a friend', 'play the computer', 'play a saved game']
    choices.each_with_index do |c, i|
      puts " enter[#{i + 1}] to #{c}  ".colorize(:green)
    end
    puts
    print ' game mode: '.colorize(:magenta)
    choice = gets.chomp
  end
  choice
end

game = Game.new
choice = player_choice

case choice
when '1'
  game.start_game
  game.play_game
when '2'
  game = Game.new(Board.new, Player.new, Player.new('CPU'))
  game.start_game
  game.play_game
when '3'
  game.load_game
end
