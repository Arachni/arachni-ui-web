class CreateUsersScanGroupsJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_join_table :users, :scan_groups
  end
end
