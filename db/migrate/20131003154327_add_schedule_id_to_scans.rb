class AddScheduleIdToScans < ActiveRecord::Migration
  def change
    add_column :scans, :schedule_id, :integer
  end
end
