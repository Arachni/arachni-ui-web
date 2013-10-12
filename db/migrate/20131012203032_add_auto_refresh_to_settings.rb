class AddAutoRefreshToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :scan_auto_refresh, :boolean, default: true
  end
end
