class RenameDescriptionOfChapters < ActiveRecord::Migration
  def change
    rename_column :chapters, :decription, :description
  end
end
