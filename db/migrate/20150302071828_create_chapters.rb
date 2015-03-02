class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :number, null: false, default: ""
      t.string :title, null: false, default: ""
      t.text :decription, null: true
      t.integer :weight, null: false, default: "999"
      t.boolean :is_active, null: false, default: false

      t.timestamps
    end
  end
end
