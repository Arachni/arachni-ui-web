class CreateProfilesUsersJoinTable < ActiveRecord::Migration[4.2]
    def change
        create_table :profiles_users, id: false do |t|
            t.integer :user_id
            t.integer :profile_id
        end
    end
end
