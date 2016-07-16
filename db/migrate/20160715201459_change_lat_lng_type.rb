class ChangeLatLngType < ActiveRecord::Migration
  def up
    change_column :users, :lat, :float
    change_column :users, :long, :float
    rename_column :users, :long, :lng
  end

  def down
    change_column :users, :lat, :string
    change_column :users, :lng, :string
    rename_column :users, :lng, :long
  end
end
