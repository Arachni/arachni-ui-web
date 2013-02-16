class CreateScanGroupsScansJoinTable < ActiveRecord::Migration
  def change
    create_join_table :scan_groups, :scans
  end
end
