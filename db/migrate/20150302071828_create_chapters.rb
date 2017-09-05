class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :number, null: false, default: ""
      t.string :title, null: false, default: ""
      t.text :description, null: true
      t.integer :weight, null: false, default: "999"
      t.integer :status, :null => false, :default => 0

      t.timestamps
    end
  end
end
