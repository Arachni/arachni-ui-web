class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.string :name
      t.integer :global_scan_limit
      t.integer :per_user_scan_limit
      t.text :target_whitelist_patterns
      t.text :target_blacklist_patterns

      t.timestamps
    end
  end
end
