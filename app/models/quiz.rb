class Quiz < ActiveRecord::Base
  belongs_to :chapter
  has_many :answers

  def is_passed_by_user user_id
    Answer.joins(:judgement)
          .exists?(quiz_id: self.id, user_id: user_id, status: Answer.statuses[:done], judgements: { result: Judgement.results[:pass] })
  end

  def is_answer_repeat_by_user user_id
    statuses = [Answer.statuses[:queue], Answer.statuses[:judgement]]
    is_not_done = Answer.exists?(quiz_id: self.id, status: statuses, user_id: user_id)
    is_quiz_passed = is_passed_by_user user_id
    return is_not_done || is_quiz_passed
  end

  def get_answer_logs_by_user user_id
    answers = Answer.where(quiz_id: self.id, user_id: user_id)
                    .where(status: Answer.statuses[:done])
                    .order("created_at ASC")
    return answers
  end
end
