class AddScheduleIdToScans < ActiveRecord::Migration[4.2]
    def change
        add_column :scans, :schedule_id, :integer

        (Scan.find_each || []).each do |scan|
            next if scan.schedule

            schedule_id = scan.root ? scan.root.schedule_id : Schedule.create( basetime: :started_at ).id
            Scan.update_all( { schedule_id: schedule_id }, { id: scan.id } )
        end
    end
end
