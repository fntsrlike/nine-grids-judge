class Answer < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :user
  has_one :judgement
end
