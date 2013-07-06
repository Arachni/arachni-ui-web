class AddIdentifierToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :identifier, :string
  end
end
