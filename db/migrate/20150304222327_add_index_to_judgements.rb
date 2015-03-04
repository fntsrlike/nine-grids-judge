class AddIndexToJudgements < ActiveRecord::Migration
  def change
    remove_index :judgements, :answer_id
    add_index :judgements, :answer_id, unique: true
  end
end
