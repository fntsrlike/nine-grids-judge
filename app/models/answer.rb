class Answer < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :user
  has_one :judgement

  enum status: [ :queue, :judgement, :pass, :reject ]

  validates_presence_of :content, :user_id
end
