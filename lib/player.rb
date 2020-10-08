# frozen_string_literal: true

class Player
  include Display
  attr_reader :displayed_color, :symbolic_color, :name
  attr_accessor :winner

  def initialize
    @name = ''
    @displayed_color = ''
    @symbolic_color = nil
    @winner = false
  end

  def request_info
    request_name
    request_color
  end

  def request_name
    name = gets.chomp
    loop do
      break if valid_name?(name)

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

      print ' please enter 1 or 2: '
      choice = gets.chomp.to_i
    end
    assign_color(choice)
  end

  def show_color_choices
    puts
    puts ' Player 1 will now choose a color. Player 2 will be the opposite color.'
    puts
    puts " #{@name}, would you like to be White or Black?"
    print " Enter 1 for #{WHITE}  (white), or 2 for #{BLACK}  (black): "
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
