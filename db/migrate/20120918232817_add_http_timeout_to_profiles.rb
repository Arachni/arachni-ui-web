class AddHttpTimeoutToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :http_timeout, :integer
  end
end
