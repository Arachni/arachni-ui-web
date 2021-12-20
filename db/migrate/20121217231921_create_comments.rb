class CreateComments < ActiveRecord::Migration[4.2]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :commentable_id
      t.string  :commentable_type
      t.text :text

      t.timestamps
    end
  end
end
