class AddReferenceToQuizzes < ActiveRecord::Migration
  def change
    add_column :quizzes, :reference, :text
  end
end
