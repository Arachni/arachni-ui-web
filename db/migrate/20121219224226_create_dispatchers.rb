class CreateDispatchers < ActiveRecord::Migration[4.2]
    def change
        create_table :dispatchers do |t|
            t.integer :owner_id
            t.boolean :global
            t.boolean :default
            t.string :address
            t.integer :port
            t.float :score
            t.text :description
            t.text :statistics
            t.boolean :alive, default: nil

            t.timestamps
        end
    end
end
