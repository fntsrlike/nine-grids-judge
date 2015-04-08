class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :omniauthable, :registerable,
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :grids
  has_many :answers
  has_many :judgements

  scope :id, -> id { where(id: id) }
  scope :role, -> role { with_role(role) }
  scope :username, -> username { where(User.arel_table[:username].matches("%#{username}%")) }
  scope :passed_chapter, -> chapters { filter_by_passed_chapter(chapters) }
  scope :failed_chapter, -> chapters { filter_by_failed_chapter(chapters) }

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

  def self.filter_by_passed_chapter chapters
    users = User.all
    chapters.each do |chapter|
      ids = User.joins(:grids)
              .where(grids: {status: Grid.statuses[:pass]})
              .where(grids: {chapter_id: chapter})
              .map { |user| user.id }
      users = users.where(id: ids)
    end
    return users
  end

  def self.filter_by_failed_chapter chapters
    users = User.where.not(id: User.filter_by_passed_chapter(chapters).map { |user| user.id } )
    return users
  end
end
