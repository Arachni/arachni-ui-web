class CreateDispatchers < ActiveRecord::Migration
  def change
    create_table :dispatchers do |t|
      t.string :address
      t.integer :port
      t.text :description
      t.text :statistics
      t.boolean :alive, default: nil

      t.timestamps
    end
  end
end
