class CreateScansUsersJoinTable < ActiveRecord::Migration
    def change
        create_table :scans_users, id: false do |t|
            t.integer :user_id
            t.integer :scan_id
        end
    end
end
