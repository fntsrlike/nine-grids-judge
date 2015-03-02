class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :user, index: true
      t.text :content
      t.integer :status

      t.timestamps
    end
  end
end
