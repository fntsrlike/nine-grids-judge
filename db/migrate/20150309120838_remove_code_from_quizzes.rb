class RemoveCodeFromQuizzes < ActiveRecord::Migration
  def change
    remove_column(:quizzes , :code)
  end
end
