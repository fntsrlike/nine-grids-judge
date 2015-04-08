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

  def get_passed_submits_count
    return Judgement.joins(:answer).where(result: 1, answers: {quiz_id: self.id}).count
  end

  def get_failed_submits_count
    return Judgement.joins(:answer).where(result: 0, answers: {quiz_id: self.id}).count
  end

  def get_all_submits_count
    return Judgement.joins(:answer).where(answers: {quiz_id: self.id}).count
  end

  def get_passed_submit_rate
    sum = get_all_submits_count
    return (sum ==0) ? 0 : (get_passed_submits_count / get_all_submits_count) * 100
  end

  def get_all_assignee_count
    Grid.contain_quiz(self.id).count
  end

  def get_all_assignee
    assignees = Grid.select("user_id").contain_quiz(self.id).map {|assignee| assignee.user_id }
    User.find(assignees)
  end

  def get_passed_assignee
    assignees = Judgement.select("answers.user_id as assignee_id").joins(:answer).where(result: Judgement.results[:pass], answers: {quiz_id: self.id}).map { |judgement| judgement.assignee_id }
    User.find(assignees)
  end

  def get_failed_assignee
    get_all_assignee - get_passed_assignee
  end

  def get_answered_assignee_count
    assignees = Grid.select("user_id").contain_quiz(self.id).map {|assignee| assignee.user_id }
    Answer.where(quiz_id: self.id, user_id: assignees).distinct.count(:user_id)
  end

  def get_silent_assignee_count
    get_all_assignee_count - get_answered_assignee_count
  end

  def get_passed_assignee_rate
    sum = get_all_assignee_count
    return (sum ==0) ? 0 : (get_passed_submits_count.to_f / get_all_assignee_count.to_f) * 100
  end
end
