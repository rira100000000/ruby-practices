#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'game'

def option_perse
  opt = OptionParser.new
  opt.on('score', 'ボーリングのスコアを,区切りで入力してください。')
  opt.banner = 'ボーリングのスコアを,区切りで入力してください。'
  opt.parse(ARGV)
  ARGV
end

game = Game.new(option_perse[0])
puts game.calc_game.sum
