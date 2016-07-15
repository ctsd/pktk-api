class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.integer :user_id
      t.string :lat
      t.string :long

      t.timestamps null: false
    end
  end
end
