class Judgement < ActiveRecord::Base
  belongs_to :answer
  belongs_to :user
  enum result: [ :reject, :pass ]

  scope :chapter, -> chapter { joins(answer: :quiz).where(quizzes: {chapter_id: chapter}) }
  scope :quiz, -> quiz { joins(:answer).where(answers: {quiz_id: quiz}) }
  scope :examinee, -> examinee { joins(:answer).where(answers:{ user_id: examinee}) }
  scope :reviewer, -> reviewer { where(user_id: reviewer) }

  scope :result, -> result { where(result: result) }
  scope :passed, -> { where(result: Judgement.results[:pass]) }
  scope :rejected, -> { where(result: Judgement.results[:reject]) }

  scope :period_from, -> period_from { where("? <= created_at ", period_from) }
  scope :period_end, -> period_end { where("created_at <= ?", period_end) }

  scope :answer, -> key_word { search_answer(key_word) }
  scope :judgement, -> key_word { search(key_word) }

  def self.today()
    where("judgements.created_at >= ?", Time.zone.now.beginning_of_day)
  end

  def self.search key_word
    Judgement.select(Judgement.arel_table[Arel.star]).where(Judgement.arel_table[:content].matches("%#{key_word}%"))
  end

  def self.search_answer key_word
    Judgement.select(Judgement.arel_table[Arel.star]).where(Answer.arel_table[:content].matches("%#{key_word}%")).joins(
      Judgement.arel_table.join(Answer.arel_table).on(
        Answer.arel_table[:id].eq(Judgement.arel_table[:answer_id])
      ).join_sources
    )
  end
end
