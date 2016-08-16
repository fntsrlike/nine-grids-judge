class Chapter < ActiveRecord::Base

  # Relationship
  has_many :quizzes
  has_many :grids

  # Enum
  enum status: [ :inactive, :active ]

  # 本章節已通過的使用者數量
  def get_pass_people_count
    Grid.where(chapter_id: self.id, status: 1).count
  end

  # 挑戰本章節的使用者數量
  def get_all_people_count
    Grid.where(chapter_id: self.id).count
  end

  # 本章節已通過的使用者比例
  def get_pass_people_rate
    get_pass_people_count.to_f / get_all_people_count.to_f * 100.0
  end

  # 本章節提交還在佇列中的數量
  def get_queue_count
    Answer.joins(:quiz).where(status: [0,1], quizzes: {chapter_id: self.id}).count
  end

  # 本章節提交被審定為通過的數量
  def get_pass_submit_count
    Judgement.joins(answer: :quiz).where(result: 1, quizzes: {chapter_id: self.id}).count
  end

  # 本章節提交被審定為駁回的數量
  def get_reject_submit_count
    Judgement.joins(answer: :quiz).where(result: 0, quizzes: {chapter_id: self.id}).count
  end

  # 本章節所有提交的數量
  def get_all_submit_count
    Answer.joins(:quiz).where(quizzes: {chapter_id: self.id}).count
  end

  # 本章節擁有題目的數量
  def get_all_quizzes_count
    Quiz.where(chapter_id: self.id).count
  end
end
