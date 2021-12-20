class AddIdentifierToNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :identifier, :string
  end
end
