class Judgement < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  enum result: [ :reject, :pass ]

  after_save :rejudge_grid

  private
    def rejudge_grid
      judgement = self
      answer = self.answer
      grid = Grid.where(user_id: answer.user.id, chapter_id: answer.quiz.chapter_id ).first
      grid.update_status
    end
end
