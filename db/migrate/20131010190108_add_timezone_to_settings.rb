class AddTimezoneToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :timezone, :string, default: 'Etc/UTC'
  end
end
