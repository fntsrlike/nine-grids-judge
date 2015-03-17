class Chapter < ActiveRecord::Base
  has_many :quizzes
  has_many :grids

  enum status: [ :inactive, :active ]

  def get_pass_count
    return Grid.where(chapter_id: self.id, status: 1).count
  end

  def get_all_count
    return Grid.where(chapter_id: self.id).count
  end

  def get_pass_rate
    return get_pass_count.to_f / get_all_count.to_f * 100.0
  end
end
