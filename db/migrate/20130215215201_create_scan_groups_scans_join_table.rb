class CreateScanGroupsScansJoinTable < ActiveRecord::Migration[4.2]
  def change
    create_join_table :scan_groups, :scans
  end
end
