class RemoveMinPagesPerInstanceFromProfiles < ActiveRecord::Migration
  def up
    remove_column :profiles, :min_pages_per_instance
  end

  def down
    add_column :profiles, :min_pages_per_instance, :integer
  end
end
