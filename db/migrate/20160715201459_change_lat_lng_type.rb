class ChangeLatLngType < ActiveRecord::Migration
  def up
    remove_column :users, :lat
    remove_column :users, :long
    add_column :users, :lat, :float, null: false
    add_column :users, :lng, :float, null: false
  end

  def down
    remove_column :users, :lat
    remove_column :users, :long
    add_column :users, :lat, :string, null: false
    add_column :users, :long, :string, null: false
  end
end
