class Chapter < ActiveRecord::Base
  has_many :quizzes
  has_many :grids
end
