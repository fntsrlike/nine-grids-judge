class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.string :code, null: false, default: ""
      t.string :title, null: false, default: ""
      t.text :content, null: true
      t.references :chapter, index: true

      t.timestamps
    end
  end
end
