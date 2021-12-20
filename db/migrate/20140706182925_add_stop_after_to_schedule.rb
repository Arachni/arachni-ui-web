class AddStopAfterToSchedule < ActiveRecord::Migration[4.2]
  def change
    add_column :schedules, :stop_after, :integer
    add_column :schedules, :stop_suspend, :boolean
  end
end
