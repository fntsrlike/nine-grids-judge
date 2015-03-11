class Grid < ActiveRecord::Base
  belongs_to :user
  belongs_to :chapter

  enum status: [ :fail, :pass ]

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

  def update_status
    status = ""
    is_pass = false
    pass_combos = [
      0b111000000, 0b000111000, 0b000000111, # |
      0b100100100, 0b010010010, 0b001001001, # -
      0b100010001, 0b001010100               # x
    ]

    self.get_quizzes.each do |quiz|
      is_quiz_pass = Answer.joins(:judgement)
        .exists?(quiz_id: quiz.id, user_id: self.user_id, status: 2, judgements: { result: 1 })
      status += is_quiz_pass ? "1" : "0"
    end

    pass_combos.each do |combo|
      if combo == status.to_i(2) & combo
        is_pass = true
        break
      end
    end

    is_pass ? self.pass! : self.fail!
  end
end
