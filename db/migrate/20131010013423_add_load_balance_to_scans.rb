class AddLoadBalanceToScans < ActiveRecord::Migration
  def change
    add_column :scans, :load_balance, :boolean
  end
end
