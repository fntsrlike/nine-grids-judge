class AddStudentFilesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :realname, :string
    add_column :users, :phone, :string
  end
end
