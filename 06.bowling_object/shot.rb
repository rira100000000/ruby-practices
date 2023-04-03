# frozen_string_literal: true

# 1投を表すクラス
class Shot
  attr_reader :score

  def initialize(shot_score)
    @score = shot_score
  end
end
