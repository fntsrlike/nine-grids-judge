class Judgement < ActiveRecord::Base
  # Relationship
  belongs_to(:answer)
  belongs_to(:user)

  # Enum
  enum(result: [ :reject, :pass ])

  # HasScope Gem: resources filter
  # Ref: https://github.com/plataformatec/has_scope
  scope(:chapter, -> chapter { joins(answer: :quiz).where(quizzes: {chapter_id: chapter}) })
  scope(:quiz, -> quiz { joins(:answer).where(answers: {quiz_id: quiz}) })
  scope(:examinee, -> examinee { joins(:answer).where(answers:{ user_id: examinee}) })
  scope(:reviewer, -> reviewer { where(user_id: reviewer) })
  scope(:result, -> result { where(result: result) })
  scope(:passed, -> { where(result: Judgement.results[:pass]) })
  scope(:rejected, -> { where(result: Judgement.results[:reject]) })
  scope(:period_from, -> period_from { where("? <= created_at ", period_from) })
  scope(:period_end, -> period_end { where("created_at <= ?", period_end) })
  scope(:answer, -> key_word { search_answer(key_word) })
  scope(:judgement, -> key_word { search(key_word) })

  # 萃取今天提交的裁決
  def self.today
    where("judgements.created_at >= ?", Time.zone.now.beginning_of_day)
  end

  # 萃取內文有指定關鍵字的裁決
  # Arel's ref: https://github.com/rails/arel
  def self.search(key_word)
    Judgement.select(Judgement.arel_table[Arel.star]).where(Judgement.arel_table[:content].matches("%#{key_word}%"))
  end

  # 萃取所屬解答的內文有指定關鍵字的裁決
  # Arel's and arel_table's ref: https://github.com/rails/arel
  def self.search_answer(key_word)
    Judgement.select(Judgement.arel_table[Arel.star]).where(Answer.arel_table[:content].matches("%#{key_word}%")).joins(
      Judgement.arel_table.join(Answer.arel_table).on(
        Answer.arel_table[:id].eq(Judgement.arel_table[:answer_id])
      ).join_sources
    )
  end
end
