# frozen_string_literal: true

require_relative 'frame'

# 1ゲームを表す
class Game
  def initialize(raw_scores)
    @scores = raw_scores.split(',').map do |raw_score|
      raw_score == 'X' ? 10 : raw_score.to_i
    end
  end

  def calc_game
    frames = []
    index = 0
    10.times.each do
      frame_scores = []
      frame_scores << @scores[index]
      frame_scores << @scores[index + 1]

      if @scores[index] == 10
        frame_scores << @scores[index + 2]
        index += 1
      elsif spare?(@scores[index], @scores[index + 1])
        frame_scores << @scores[index + 2]
        index += 2
      else
        index += 2
      end
      frames << Frame.new(frame_scores).frame_score
    end
    frames
  end

  def spare?(score, next_score)
    if next_score.nil?
      false
    elsif score + next_score == 10
      true
    end
  end
end
