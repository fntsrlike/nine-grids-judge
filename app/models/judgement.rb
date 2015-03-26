class Judgement < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  enum result: [ :reject, :pass ]

  def self.today()
    where("judgements.created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
