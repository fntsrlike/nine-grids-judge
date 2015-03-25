class Answer < ActiveRecord::Base
  belongs_to :quiz
  belongs_to :user
  has_one :judgement

  enum status: [ :queue, :judgement, :done ]

  validates_presence_of :content, :user_id

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
end
