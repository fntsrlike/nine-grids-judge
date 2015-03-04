class Answer < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :user
  has_one :judgement

  enum status: [ :queue, :judgement, :pass, :reject ]
end
