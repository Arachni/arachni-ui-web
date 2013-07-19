class AddHttpAuthToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :http_username, :string
    add_column :profiles, :http_password, :string
  end
end
