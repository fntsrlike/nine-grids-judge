class User < ActiveRecord::Base
  # Gem Setting
  # Ref: https://github.com/RolifyCommunity/rolify
  # Ref: https://github.com/plataformatec/devise
  rolify
  devise(:database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable)

  # Relationship
  has_many(:grids)
  has_many(:answers)
  has_many(:judgements)

  # HasScope Gem: resources filter
  # Ref: https://github.com/plataformatec/has_scope
  scope(:id, -> id { where(id: id) })
  scope(:role, -> role { with_role(role) })
  scope(:username, -> username { where(User.arel_table[:username].matches("%#{username}%")) })
  scope(:passed_chapter, -> chapters { by_passed_chapters(chapters) })
  scope(:failed_chapter, -> chapters { by_failed_chapter(chapters) })

  # CanCanCan Setting
  delegate(:can?, :cannot?, to: :ability)
  def ability
    @ability ||= Ability.new(self)
  end

  # 本使用者是否已通過指定的章節編號
  def has_passed_chapter?(chapter)
    Grid.where(user_id: self.id, status: Grid.statuses[:pass], chapter: chapter).count > 0
  end

  # 本使用者在指定章節編號裡以指定章節通過獲取分數和指定每格通過獲取分數的運算下，可獲取的分數
  def get_chapter_score(chapter, points_by_passed_chapter, grid_points)
    if self.has_passed_chapter?(chapter)
      return points_by_passed_chapter
    end

    if self.grids.where(chapter: chapter).count == 0
      return 0
    end

    passed_grid_num = Grid.where(user_id: self.id, chapter_id: chapter_id).first
                      .get_passed_quizzes.count
    if passed_grid_num * grid_points >= points_by_passed_chapter
      points_by_passed_chapter;
    else
      passed_grid_num * grid_points
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
  def self.by_passed_chapters(chapters)
    # 透過先挑選有通過這些章節的九宮格，在擷取這些九宮格的使用者名單
    passed_user_ids = Grid.where(status: :pass, chapter: chapters)
                          .having("COUNT(*) > ?", chapters.count)
                          .group(:user_id)
                          .pluck(:user_id)
    User.where(id: passed_user_ids)
  end

  # 萃取出沒有通過指定章節清單的使用者名單
  def self.by_failed_chapter(chapters)
    User.where.not(id: User.by_passed_chapters(chapters).map { |user| user.id } )
  end
end
