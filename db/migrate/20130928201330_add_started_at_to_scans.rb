class AddStartedAtToScans < ActiveRecord::Migration
  def change
    add_column :scans, :started_at, :datetime
  end
end
