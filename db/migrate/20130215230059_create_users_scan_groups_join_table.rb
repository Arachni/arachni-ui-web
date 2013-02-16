class CreateUsersScanGroupsJoinTable < ActiveRecord::Migration
  def change
    create_join_table :users, :scan_groups
  end
end
