class AddTimezoneToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :timezone, :string, default: 'Etc/UTC'
  end
end
