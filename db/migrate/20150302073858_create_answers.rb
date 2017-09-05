class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :user, index: true, :null => false
      t.references :quiz, index: true, :null => false
      t.text :content
      t.integer :status, :null => false, :default => 0

      t.timestamps
    end
  end
end
