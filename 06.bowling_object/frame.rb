# frozen_string_literal: true

require_relative 'shot'

# 1フレームを表す
class Frame
  attr_reader :frame_score

  def initialize(shots)
    @frame_score = calc_frame(shots)
  end

  def calc_frame(shots)
    shots.sum do |shot|
      one_shot = Shot.new(shot)
      one_shot.score
    end
  end
end
