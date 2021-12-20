class AddWelcomedToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :welcomed, :boolean
  end
end
