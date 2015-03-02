class CreateGrids < ActiveRecord::Migration
  def change
    create_table :grids do |t|
      t.references :user, index: true
      t.references :chapter, index: true
      t.integer :quiz_1
      t.integer :quiz_2
      t.integer :quiz_3
      t.integer :quiz_4
      t.integer :quiz_5
      t.integer :quiz_6
      t.integer :quiz_7
      t.integer :quiz_8
      t.integer :quiz_9

      t.timestamps
    end
  end
end
