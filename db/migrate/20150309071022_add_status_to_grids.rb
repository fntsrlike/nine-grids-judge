class AddStatusToGrids < ActiveRecord::Migration
  def change
    add_column :grids, :status, :integer, :default => 0, :null => false
  end
end
