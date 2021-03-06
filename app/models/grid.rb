class Grid < ActiveRecord::Base

  # Relationship
  belongs_to(:user)
  belongs_to(:chapter)

  # Enum
  enum(status: [ :fail, :pass ])

  GRID_NUMBER = 9

  # 九宮格是否含指定的題目
  def self.contain_quiz(quiz_id)
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

  def self.by_user(user)
    where(user: user)
  end

  # 本九宮格的題目陣列
  def get_quizzes
    quizzes = []
    for i in 1..GRID_NUMBER
      quizzes.push(Quiz.find(self["quiz_#{i}"]))
    end
    quizzes
  end

  # 本九宮格的題目編號陣列
  def get_quizzes_id
    quizzes = []
    for i in 1..GRID_NUMBER
      quizzes.push(self["quiz_#{i}"])
    end
    quizzes
  end

  # 本九宮格的題目通過狀態陣列
  def get_quizzes_status
    @statuses ||= get_quizzes.map do |quiz|
      case
      when quiz.is_passed_by_user?(user)
        :pass
      when quiz.is_queue_by_user?(user)
        :judgement
      else
        :fail
      end
    end
  end

  # 指定題目在本九宮格裡所在的位置
  def get_quiz_sort(quiz)
    for i in 1..GRID_NUMBER
      return i if self["quiz_#{i}"] == quiz.id
    end
    nil
  end

  # 更新本九宮個的通過狀態
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

  # 隨機設定本九宮格所擁有的題目
  def set_quizzes_random
    quizzes = Quiz.where(:chapter_id => self.chapter_id).pluck(:id).shuffle[0..8]
    attributes = {}
    for i in 1..GRID_NUMBER
      attributes["quiz_#{i}"] = quizzes[i-1]
    end
    update(attributes)
  end

  # 重設本九宮格
  def reset_user_grids
    update(get_reset_attributes)
  end

  # 將本九宮格裡未通過的題目格替換為隨機的新題目
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

    attributes
  end

  # 取得本九宮格中已通過的題目
  def get_passed_quizzes
    pass_quizzes = {}
    user.answers.where(quiz: get_quizzes, status: Answer.statuses[:done])

    get_quizzes.each_with_index do |quiz, index|
      if quiz.is_passed_by_user?(user)
        pass_quizzes[index+1] = quiz.id
      end
    end

    pass_quizzes
  end

end
