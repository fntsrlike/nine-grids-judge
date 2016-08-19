class Answer < ActiveRecord::Base

  # Relationship
  belongs_to(:quiz)
  belongs_to(:user)
  has_one(:judgement)

  # Enum
  enum(status: [:queue, :judgement, :done])

  # 檢查指定欄位不為 nil 或空字串
  validates_presence_of(:content, :user_id)

  # HasScope Gem: resources filter
  # Ref: https://github.com/plataformatec/has_scope
  scope(:chapter, -> chapter { joins(:quiz).where(quizzes: {chapter_id: chapter}) })
  scope(:quiz, -> quiz { where(quiz_id: quiz) })
  scope(:examinee, -> examinee { where(user_id: examinee) })
  scope(:status, -> status { where(status: status) })
  scope(:period_from, -> period_from { where("? <= created_at ", period_from) })
  scope(:period_end, -> period_end { where("created_at <= ?", period_end) })
  scope(:answer, -> key_word { search_answer(key_word) })

  # 助教觀看答題清單的優先順序演算法
  # 1. 沒通過該章節的優先於通過該章節的
  # 2. 當天提交次數少得優先於提交次數多的
  # 3. 先提交的優先於晚提交的
  def self.judge_piority
    select("answers.*, grids.status as grid_status, counter.count")
    .joins(:quiz, user: :grids)
    .joins("LEFT OUTER JOIN (
              SELECT `user_id`, COUNT(user_id) as `count` FROM `answers`
              WHERE `status` = 2 AND `created_at` >= '#{Time.now.beginning_of_day.getutc}'
              GROUP BY `user_id`) as `counter`
            ON `answers`.`user_id` = `counter`.`user_id`") # Need to refactor with activerecord
    .where("grids.chapter_id = quizzes.chapter_id")
    .order("grid_status ASC") # Not pass is higher than passed
    .order("count ASC")       # Judged answer less one is higher than more one (MYSQL only)
    .order("created_at ASC")  # Ealier submit is higher than later one
  end

  # 萃取今天提交的答案
  def self.today()
    where("answers.created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
