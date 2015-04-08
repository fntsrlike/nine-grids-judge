class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :grids
  has_many :answers
  has_many :judgements

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, :to => :ability

  def get_passed_chapter
    Grid.where(user_id: self.id, status: Grid.statuses[:pass]).map { |grid| grid.chapter }
  end

  def get_failed_chapter
    Grid.where(user_id: self.id, status: Grid.statuses[:fail]).map { |grid| grid.chapter }
  end

  def get_submits
    Answer.where(user_id: self.id)
  end

  def get_passed_submits
    Judgement.joins(:answer)
      .where(result: Judgement.results[:pass], answers: {user_id: self.id})
      .map { |judgement| judgement.answer }
  end

  def get_failed_submits
    Judgement.joins(:answer)
      .where(result: Judgement.results[:reject], answers: {user_id: self.id})
      .map { |judgement| judgement.answer }
  end
end
