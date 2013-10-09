class AddScheduleIdToScans < ActiveRecord::Migration
    def change
        add_column :scans, :schedule_id, :integer

        Scan.all.each do |scan|
            next if scan.schedule

            schedule_id = scan.root ? scan.root.schedule_id : Schedule.create( basetime: :started_at ).id
            Scan.update_all( { schedule_id: schedule_id }, { id: scan.id } )
        end
    end
end
