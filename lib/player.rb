require 'colorize'

class Player
  attr_reader :color
  attr_accessor :winner

  def initialize
    @name = ''
    @color = ''
    @winner = false
  end
  
  WHITE = "\u2659".colorize(:black)
  BLACK = "\u265F".colorize(:black)

  def request_info
    request_name
    request_color
  end

  def request_name
    name = gets.chomp
    loop do
      break if valid_name?(name)

      print 'please enter a valid name: '
      name = gets.chomp
    end
    @name = name
  end

  def request_color
    show_color_choices
    choice = gets.chomp.to_i
    loop do
      break if valid_color?(choice)
  
      print 'please enter 1 or 2: '
      choice = gets.chomp.to_i
    end
      assign_color(choice)
  end
  
  def show_color_choices
    puts 'Player 1 will now choose a color. Player 2 will be the opposite color.'
    sleep(1)
    puts "#{@name}, would you like to be White or Black?"
    print "Enter 1 for #{"\u265F".colorize(:light_yellow)}, 2 for #{"\u265F".colorize(:cyan)}: "
  end

  def assign_color(choice)
    if choice == 1
      puts "#{@name} is #{"\u265F".colorize(:light_yellow)}"
      @color = WHITE
    else
      puts "#{@name} is #{"\u265F".colorize(:cyan)}"
      @color = BLACK
    end
    @color = choice
  end

  def valid_name?(input)
    input.match?(/\w/)
  end

  def valid_color?(choice)
    choice == 1 || choice == 2
  end
end
