class CreateScansUsersJoinTable < ActiveRecord::Migration[4.2]
    def change
        create_table :scans_users, id: false do |t|
            t.integer :user_id
            t.integer :scan_id
        end
    end
end
