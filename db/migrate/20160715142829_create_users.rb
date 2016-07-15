class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.integer :team, null: false
      t.string :messenger_id, null: false
      t.string :lat, default: nil
      t.string :long, default: nil
      t.boolean :on, default: false

      t.timestamps null: false
    end

    create_table :messages do |t|
      t.string :text, null: false
      t.integer :user_id, null: false
      t.string :lat, null: false
      t.string :long, null: false

      t.timestamps null: false
    end
  end
end
