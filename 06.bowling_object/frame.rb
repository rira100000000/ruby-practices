# frozen_string_literal: true

require_relative 'shot'

# 1フレームを表す
class Frame
  def initialize(first_shot, second_shot)
    @first_score = Shot.new(first_shot).score
    @second_score = second_shot.nil? ? 0 : Shot.new(second_shot).score
    @bonus_score = 0
  end

  def calc_frame
    @first_score + @second_score + @bonus_score
  end

  def add_bonus_score(bonus_score)
    @bonus_score = bonus_score
  end

  def spare?
    @first_score + @second_score == 10
  end

  def strike?
    @first_score == 10
  end
end
