class AddStopAfterToSchedule < ActiveRecord::Migration
  def change
    add_column :schedules, :stop_after, :integer
    add_column :schedules, :stop_suspend, :boolean
  end
end
