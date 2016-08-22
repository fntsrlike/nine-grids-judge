class Quiz < ActiveRecord::Base
  # Relationship
  belongs_to(:chapter)
  has_many(:answers)

  # 指定使用者編號是否已通過本題目
  def is_passed_by_user(user_id)
    Answer.joins(:judgement)
          .exists?(quiz_id: self.id, user_id: user_id, status: Answer.statuses[:done], judgements: { result: Judgement.results[:pass] })
  end

  # 指定使用者編號是否有權限回答本題目
  def is_answer_repeat_by_user(user_id)
    statuses = [Answer.statuses[:queue], Answer.statuses[:judging]]
    is_not_done = Answer.exists?(quiz_id: self.id, status: statuses, user_id: user_id)
    is_quiz_passed = is_passed_by_user user_id

    is_not_done || is_quiz_passed
  end

  # 取得指定使用者編號回答本題目的提交紀錄
  def get_answer_logs_by_user(user_id)
    Answer.where(quiz_id: self.id, user_id: user_id)
                    .where(status: Answer.statuses[:done])
                    .order("created_at ASC")
  end

  # 取得所有提交裡通過本題目的數量
  def get_passed_submits_count
    Judgement.joins(:answer).where(result: 1, answers: {quiz_id: self.id}).count
  end

  # 取得所有提交裡沒有通過本題目的數量
  def get_failed_submits_count
    Judgement.joins(:answer).where(result: 0, answers: {quiz_id: self.id}).count
  end

  # 取得所本題目所有提交的數量
  def get_all_submits_count
    Judgement.joins(:answer).where(answers: {quiz_id: self.id}).count
  end

  # 取得本題目的以總提交數為分母的通過率
  def get_passed_submit_rate
    sum = get_all_submits_count
    (sum ==0) ? 0 : (get_passed_submits_count / get_all_submits_count) * 100
  end

  # 取得本題目挑戰者的數量
  def get_all_assignee_count
    Grid.contain_quiz(self.id).count
  end

  # 取得本題目的挑戰者清單
  def get_all_assignee
    assignees = Grid.select("user_id").contain_quiz(self.id).map {|assignee| assignee.user_id }
    User.find(assignees)
  end

  # 取得通過本題目的挑戰者清單
  def get_passed_assignee
    assignees = Judgement.select("answers.user_id as assignee_id").joins(:answer).where(result: Judgement.results[:pass], answers: {quiz_id: self.id}).map { |judgement| judgement.assignee_id }
    User.find(assignees)
  end

  # 取得沒有通過本題目的挑戰者清單
  def get_failed_assignee
    get_all_assignee - get_passed_assignee
  end

  # 取得曾經回答過本題目的挑戰者的數量
  def get_answered_assignee_count
    assignees = Grid.select("user_id").contain_quiz(self.id).map {|assignee| assignee.user_id }
    Answer.where(quiz_id: self.id, user_id: assignees).distinct.count(:user_id)
  end

  # 取得還沒提交任何解的挑戰者數量
  def get_silent_assignee_count
    get_all_assignee_count - get_answered_assignee_count
  end

  # 取得本題目以挑戰者為分母的通過率
  def get_passed_assignee_rate
    sum = get_all_assignee_count
    (sum ==0) ? 0 : (get_passed_submits_count.to_f / get_all_assignee_count.to_f) * 100
  end

  def get_sort_by_user(user)
    grid = chapter.grids.by_user(user).first
    grid&.get_quiz_sort(self)
  end

  def is_passed_by_user?(user)
    answers.includes(:judgement).where(user: user).exists?(judgements: { result: Judgement.results[:pass] } )
  end

  def is_queue_by_user?(user)
    answers.where(user: user).exists?(status: [Answer.statuses[:queue], Answer.statuses[:judging]])
  end
end
