class CreateDispatchersUsersJoinTable < ActiveRecord::Migration[4.2]
  def change
      create_join_table :dispatchers, :users
  end
end
