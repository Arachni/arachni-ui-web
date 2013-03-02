class CreateDispatchersUsersJoinTable < ActiveRecord::Migration
  def change
      create_join_table :dispatchers, :users
  end
end
