class Judgement < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user

  enum result: [ :reject, :pass ]
end
