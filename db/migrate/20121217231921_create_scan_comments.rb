class CreateScanComments < ActiveRecord::Migration
  def change
    create_table :scan_comments do |t|
      t.integer :user_id
      t.integer :scan_id
      t.text :text

      t.timestamps
    end
  end
end
