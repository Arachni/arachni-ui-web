class RemoveReportsFromProfile < ActiveRecord::Migration
    def up
        remove_column :profiles, :reports
    end

    def down
        add_column :profiles, :reports, :string
    end
end
