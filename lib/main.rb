# frozen_string_literal: true

require 'pry'
require 'colorize'
require_relative './modules/display'
require_relative './modules/setup_board_variables'
require_relative './modules/adjacency_list_generator'
require_relative './modules/input_validator'
require_relative './modules/move_validator'
require_relative './modules/move_disambiguator'
require_relative './modules/castle_manager'
require_relative './modules/checkmate_manager'
require_relative './modules/serializer'
require_relative './game'
require_relative './board'
require_relative './empty_square'
require_relative './player'
require_relative './rook'
require_relative './knight'
require_relative './bishop'
require_relative './king'
require_relative './queen'
require_relative './pawn'

game = Game.new
game.start_game
game.play_game
