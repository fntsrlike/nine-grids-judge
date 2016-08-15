class Grid < ActiveRecord::Base
  belongs_to :user
  belongs_to :chapter

  enum status: [ :fail, :pass ]
  GRID_NUMBER = 9

  def self.contain_quiz quiz_id
    where(
      Arel::Nodes::Group.new(
        Grid.arel_table[:quiz_1].eq(quiz_id)
          .or(Grid.arel_table[:quiz_2].eq(quiz_id)
          .or(Grid.arel_table[:quiz_3].eq(quiz_id)
          .or(Grid.arel_table[:quiz_4].eq(quiz_id)
          .or(Grid.arel_table[:quiz_5].eq(quiz_id)
          .or(Grid.arel_table[:quiz_6].eq(quiz_id)
          .or(Grid.arel_table[:quiz_7].eq(quiz_id)
          .or(Grid.arel_table[:quiz_8].eq(quiz_id)
          .or(Grid.arel_table[:quiz_9].eq(quiz_id)
        ))))))))
      )
    )
  end

  def get_quizzes
    quizzes = []
    for i in 1..GRID_NUMBER
      quizzes.push(Quiz.find(self["quiz_#{i}"]))
    end
    return quizzes
  end

  def get_quizzes_id
    quizzes = []
    for i in 1..GRID_NUMBER
      quizzes.push(self["quiz_#{i}"])
    end
    return quizzes
  end

  def get_quizzes_status
    status = Array.new(GRID_NUMBER,0)
    get_quizzes.each_with_index do |quiz, index|
      if Answer.joins(:judgement).exists?(quiz_id: quiz.id, user_id: self.user_id, status: Answer.statuses[:done], judgements: { result: Judgement.results[:pass] })
        status[index] = 2
      elsif Answer.exists?(:quiz_id => quiz.id, :user_id => self.user_id, :status => [Answer.statuses[:queue], Answer.statuses[:judgement]])
        status[index] = 1
      else
        status[index] = 0
      end
    end
    return status
  end

  def get_quiz_sort quiz_id
    for i in 1..GRID_NUMBER
      return i if self["quiz_#{i}"] == quiz_id
    end
    return nil
  end

  def update_status
    status = ""
    is_pass = false
    pass_combos = [
      0b111000000, 0b000111000, 0b000000111, # |
      0b100100100, 0b010010010, 0b001001001, # -
      0b100010001, 0b001010100               # x
    ]

    get_quizzes.each do |quiz|
      is_quiz_pass = Answer.joins(:judgement)
        .exists?(quiz_id: quiz.id, user_id: self.user_id, status: Answer.statuses[:done], judgements: { result: Judgement.results[:pass] })
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

  def set_quizzes_random
    quizzes = Quiz.where(:chapter_id => self.chapter_id).pluck(:id).shuffle[0..8]
    attributes = {}
    for i in 1..GRID_NUMBER
      attributes["quiz_#{i}"] = quizzes[i-1]
    end
    update(attributes)
  end

  def reset_user_grids
    update(get_reset_attributes)
  end

  def get_reset_attributes
    pass_quizzes = get_passed_quizzes
    fail_quizzes_count = GRID_NUMBER - pass_quizzes.count

    new_quizzes = Quiz.where(:chapter_id => self.chapter_id).where.not(id: pass_quizzes.values)
                      .pluck(:id).shuffle[0..fail_quizzes_count]

    attributes = {}
    for i in 1..GRID_NUMBER
      if pass_quizzes[i].nil?
        attributes["quiz_#{i}"] = new_quizzes.pop
      end
    end

    return attributes
  end

  def get_passed_quizzes
    pass_quizzes = {}
    get_quizzes.each_with_index do |quiz, index|
      if Answer.joins(:judgement).exists?(quiz_id: quiz.id, user_id: self.user_id, status: Answer.statuses[:done], judgements: { result: Judgement.results[:pass] })
        pass_quizzes[index+1] = quiz.id
      end
    end

    return pass_quizzes
  end

end
