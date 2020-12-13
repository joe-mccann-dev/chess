# frozen_string_literal: true

# hold player information, handles color selection
class Player
  include Display
  attr_reader :displayed_color, :symbolic_color, :name

  def initialize(name = '')
    @name = name
    @displayed_color = ''
    @symbolic_color = nil
  end

  def request_info
    request_name
    request_color
  end

  def request_name
    return if @name == 'CPU'

    name = gets.chomp
    loop do
      break if valid_name?(name)

      puts "name 'CPU' reserved for computer player" if name == 'CPU'
      print ' please enter a valid name: '
      name = gets.chomp
    end
    @name = name
  end

  def request_color
    show_color_choices
    choice = gets.chomp.to_i
    loop do
      break if valid_color?(choice)

      puts ' enter[1] for White'.colorize(:red)
      puts " enter[2] for Black \n".colorize(:red)
      print ' color choice: '.colorize(:magenta)
      choice = gets.chomp.to_i
    end
    assign_color(choice)
  end

  def show_color_choices
    puts
    puts " #{@name}, would you like to be White or Black?"
    puts
    puts ' enter[1] for White'.colorize(:green)
    puts " enter[2] for Black \n".colorize(:green)
    print ' color choice: '.colorize(:magenta)
  end

  def assign_color(choice)
    if choice == 1
      @displayed_color = WHITE
      @symbolic_color = :white
    else
      @displayed_color = BLACK
      @symbolic_color = :black
    end
    puts
    puts " #{@name} is #{@displayed_color}"
  end

  def valid_name?(input)
    input.match?(/\w/)
  end

  def valid_color?(choice)
    choice == 1 || choice == 2
  end
end
