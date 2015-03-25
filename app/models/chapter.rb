class Chapter < ActiveRecord::Base
  has_many :quizzes
  has_many :grids

  enum status: [ :inactive, :active ]

  def get_pass_people_count
    return Grid.where(chapter_id: self.id, status: 1).count
  end

  def get_all_people_count
    return Grid.where(chapter_id: self.id).count
  end

  def get_pass_people_rate
    return get_pass_people_count.to_f / get_all_people_count.to_f * 100.0
  end

  def get_queue_count
    return Answer.joins(:quiz).where(status: [0,1], quizzes: {chapter_id: self.id}).count
  end

  def get_pass_submit_count
    Judgement.joins(answer: :quiz).where(result: 1, quizzes: {chapter_id: self.id}).count
  end

  def get_reject_submit_count
    Judgement.joins(answer: :quiz).where(result: 0, quizzes: {chapter_id: self.id}).count
  end

  def get_all_submit_count
    return Answer.joins(:quiz).where(quizzes: {chapter_id: self.id}).count
  end

  def get_all_quizzes_count
    return Quiz.where(chapter_id: self.id).count
  end
end
