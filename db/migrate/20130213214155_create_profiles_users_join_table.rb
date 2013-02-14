class CreateProfilesUsersJoinTable < ActiveRecord::Migration
    def change
        create_table :profiles_users, id: false do |t|
            t.integer :user_id
            t.integer :profile_id
        end
    end
end
