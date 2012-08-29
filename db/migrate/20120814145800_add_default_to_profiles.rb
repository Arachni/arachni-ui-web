class AddDefaultToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :default, :boolean
  end
end
