class CreateScanGroups < ActiveRecord::Migration[4.2]
  def change
    create_table :scan_groups do |t|
      t.string :name
      t.text :description
      t.integer :owner_id

      t.timestamps
    end
  end
end
