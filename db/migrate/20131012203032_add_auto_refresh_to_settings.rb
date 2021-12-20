class AddAutoRefreshToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :scan_auto_refresh, :boolean, default: true
  end
end
