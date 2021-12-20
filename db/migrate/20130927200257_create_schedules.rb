class CreateSchedules < ActiveRecord::Migration[4.2]
  def change
    create_table :schedules do |t|
      t.datetime :start_at

      t.integer :every_minute
      t.integer :every_hour
      t.integer :every_day
      t.integer :every_month

      t.string  :basetime

      t.timestamps
    end
  end
end
