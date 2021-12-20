class CreateNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string :model_type
      t.integer :model_id
      t.string :action
      t.integer :actor_id
      t.text :text
      t.boolean :read, default: false

      t.timestamps
    end
  end
end
