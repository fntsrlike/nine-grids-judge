class Answer < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :user
  has_one :judgement

  enum status: [ :queue, :judgement, :done ]

  validates_presence_of :content, :user_id

  scope :chapter, -> chapter { joins(:quiz).where(quizzes: {chapter_id: chapter}) }
  scope :quiz, -> quiz { where(quiz_id: quiz) }
  scope :examinee, -> examinee { where(user_id: examinee) }

  scope :status, -> status { where(status: status) }

  scope :period_from, -> period_from { where("? <= created_at ", period_from) }
  scope :period_end, -> period_end { where("created_at <= ?", period_end) }

  scope :answer, -> key_word { search_answer(key_word) }


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

  def self.today(is_join = false)
    where("answers.created_at >= ?", Time.zone.now.beginning_of_day)
  end
end
