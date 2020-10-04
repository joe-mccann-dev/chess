# frozen_string_literal: true

require 'pry'
require 'colorize'
require_relative './modules/display.rb'
require_relative './modules/setup_board_variables.rb'
require_relative './modules/adjacency_list_generator.rb'
require_relative './modules/input_validator.rb'
require_relative './modules/move_validator.rb'
require_relative './modules/move_disambiguator.rb'
require_relative './game.rb'
require_relative './board.rb'
require_relative './player.rb'
require_relative './rook.rb'
require_relative './knight.rb'
require_relative './bishop.rb'
require_relative './king.rb'
require_relative './queen.rb'
require_relative './pawn.rb'

game = Game.new
game.start_game
game.play_game
