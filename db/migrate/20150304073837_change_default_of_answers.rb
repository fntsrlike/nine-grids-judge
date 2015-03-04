class ChangeDefaultOfAnswers < ActiveRecord::Migration
  def change
    change_column :answers, :quiz_id, :integer, :null => false
    change_column :answers, :status, :integer, :default => 0, :null => false
  end
end
