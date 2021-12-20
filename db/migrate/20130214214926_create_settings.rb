class CreateSettings < ActiveRecord::Migration[4.2]
  def change
    create_table :settings do |t|
      t.string :name
      t.integer :scan_global_limit
      t.integer :scan_per_user_limit
      t.text :scan_target_whitelist_patterns
      t.text :scan_target_blacklist_patterns
      t.text :scan_allowed_types

      t.text :profile_allowed_modules
      t.text :profile_allowed_plugins

      t.timestamps
    end
  end
end
