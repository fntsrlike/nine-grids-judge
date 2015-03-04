class AddStatusToChapter < ActiveRecord::Migration
  def change
    rename_column :chapters, :is_active, :status
    change_column :chapters, :status, :integer, :default => 0, :null => false
  end
end
