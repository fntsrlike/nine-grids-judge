class User < ActiveRecord::Base
  # Gem Setting
  # Ref: https://github.com/RolifyCommunity/rolify
  # Ref: https://github.com/plataformatec/devise
  rolify
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  # Relationship
  has_many :grids
  has_many :answers
  has_many :judgements

  # HasScope Gem: resources filter
  # Ref: https://github.com/plataformatec/has_scope
  scope :id, -> id { where(id: id) }
  scope :role, -> role { with_role(role) }
  scope :username, -> username { where(User.arel_table[:username].matches("%#{username}%")) }
  scope :passed_chapter, -> chapters { filter_by_passed_chapter(chapters) }
  scope :failed_chapter, -> chapters { filter_by_failed_chapter(chapters) }

  # CanCanCan Setting
  delegate :can?, :cannot?, :to => :ability
  def ability
    @ability ||= Ability.new(self)
  end

  # 本使用者是否已通過指定的章節編號
  def has_passed_chapter chapter_id
    Grid.where(user_id: self.id, status: Grid.statuses[:pass], chapter_id: chapter_id).count > 0
  end

  # 本使用者在指定章節編號裡以指定章節通過獲取分數和指定每格通過獲取分數的運算下，可獲取的分數
  def get_chapter_score chapter_id, passed_chapter_points, grid_points
    if self.has_passed_chapter chapter_id
      passed_chapter_points
    else
      if Grid.where(user_id: self.id, chapter_id: chapter_id).count == 0
        return 0
      end

      passed_grid_num = Grid.where(user_id: self.id, chapter_id: chapter_id).first
                        .get_passed_quizzes.count
      if passed_grid_num * grid_points >= passed_chapter_points
        return passed_chapter_points;
      else
        return passed_grid_num * grid_points
      end
    end
  end

  # 取得本使用者已經通過的章節清單
  def get_passed_chapter
    Grid.where(user_id: self.id, status: Grid.statuses[:pass]).map { |grid| grid.chapter }
  end

  # 取得本使用者沒有通過的章節清單
  def get_failed_chapter
    Grid.where(user_id: self.id, status: Grid.statuses[:fail]).map { |grid| grid.chapter }
  end

  # 取得本使用者所有的提交
  def get_submits
    Answer.where(user_id: self.id)
  end

  # 取得本使用者審核通過的提交清單
  def get_passed_submits
    Judgement.joins(:answer)
      .where(result: Judgement.results[:pass], answers: {user_id: self.id})
      .map { |judgement| judgement.answer }
  end

  # 取得本使用者審核駁回的提交清單
  def get_failed_submits
    Judgement.joins(:answer)
      .where(result: Judgement.results[:reject], answers: {user_id: self.id})
      .map { |judgement| judgement.answer }
  end

  # 萃取出通過指定章節編號清單的使用者名單
  def self.filter_by_passed_chapter(chapters)
    users = User.all
    chapters.each do |chapter|
      ids = User.joins(:grids)
              .where(grids: {status: Grid.statuses[:pass]})
              .where(grids: {chapter_id: chapter})
              .map { |user| user.id }
      users = users.where(id: ids)
    end

    users
  end

  # 萃取出沒有通過指定章節清單的使用者名單
  def self.filter_by_failed_chapter(chapters)
    User.where.not(id: User.filter_by_passed_chapter(chapters).map { |user| user.id } )
  end
end
