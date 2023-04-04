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
      frame = Frame.new(@scores[index], @scores[index + 1])

      if frame.strike?
        frame.add_bonus_score(@scores[index + 2])
        index += 1
      elsif frame.spare?
        frame.add_bonus_score(@scores[index + 2])
        index += 2
      else
        index += 2
      end
      frames << frame.calc_frame
    end
    frames
  end
end
