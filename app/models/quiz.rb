class Quiz < ActiveRecord::Base
  belongs_to :chapter
  has_many :answers
end
