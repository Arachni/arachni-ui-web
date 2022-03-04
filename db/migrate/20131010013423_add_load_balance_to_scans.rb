class AddLoadBalanceToScans < ActiveRecord::Migration[4.2]
  def change
    add_column :scans, :load_balance, :boolean
  end
end
