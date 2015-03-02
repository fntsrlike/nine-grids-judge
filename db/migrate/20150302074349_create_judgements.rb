class CreateJudgements < ActiveRecord::Migration
  def change
    create_table :judgements do |t|
      t.references :answer, index: true
      t.references :user, index: true
      t.text :content

      t.timestamps
    end
  end
end
