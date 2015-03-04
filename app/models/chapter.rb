class Chapter < ActiveRecord::Base
  has_many :quizzes
  has_many :grids

  enum status: [ :inactive, :active ]
end
