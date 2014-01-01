class AddStartedAtToScans < ActiveRecord::Migration
    def change
        add_column :scans, :started_at, :datetime

        Scan.all.each do |scan|
            Scan.update_all( { started_at: scan.created_at }, { id: scan.id } )
        end
    end
end
