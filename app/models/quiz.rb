class Quiz < ActiveRecord::Base
  belongs_to :chapter
  has_many :answers

  def is_passed_by_user user_id
    Answer.joins(:judgement)
          .exists?(quiz_id: self.id, user_id: user_id, status: 2, judgements: { result: 1 })
  end
end
