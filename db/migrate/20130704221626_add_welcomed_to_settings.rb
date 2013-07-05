class AddWelcomedToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :welcomed, :boolean
  end
end
