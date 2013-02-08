class AddNameColumnToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :name, :string
    add_index  :profiles, :name
  end
end
