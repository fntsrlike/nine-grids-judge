class Quiz < ActiveRecord::Base
  belongs_to :chapter
  has_many :answers

  def is_passed_by_user user_id
    Answer.joins(:judgement)
          .exists?(quiz_id: self.id, user_id: user_id, status: 2, judgements: { result: 1 })
  end

  def is_answer_repeat_by_user user_id
    is_not_done = !Answer.exists?(quiz_id: self.id, status: [0,1], user_id: user_id)
    is_quiz_passed = is_passed_by_user user_id
    return is_not_done && !is_quiz_passed
  end
end
