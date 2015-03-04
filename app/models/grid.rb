class Grid < ActiveRecord::Base
  belongs_to :user
  belongs_to :chapter

  def get_quizzes
    quizzes = []
    for i in 1..9
      quizzes.push(Quiz.find(self["quiz_#{i}"]))
    end
    return quizzes
  end

  def get_quizzes_id
    quizzes = []
    for i in 1..9
      quizzes.push(self["quiz_#{i}"])
    end
    return quizzes
  end
end
