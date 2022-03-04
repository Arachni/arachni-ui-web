class AddSuspendInfoToScans < ActiveRecord::Migration[4.2]
  def change
    add_column :scans, :suspended_at, :datetime
    add_column :scans, :snapshot_path, :string
  end
end
