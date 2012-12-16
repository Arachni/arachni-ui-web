class RemoveMaxInstancesFromProfiles < ActiveRecord::Migration
  def up
    remove_column :profiles, :max_instances
  end

  def down
    add_column :profiles, :max_instances, :integer
  end
end
