class AddSuspendInfoToScans < ActiveRecord::Migration
  def change
    add_column :scans, :suspended_at, :datetime
    add_column :scans, :snapshot_path, :string
  end
end
