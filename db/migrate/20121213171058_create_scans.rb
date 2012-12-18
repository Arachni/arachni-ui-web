class CreateScans < ActiveRecord::Migration
    def change
        create_table :scans do |t|
            t.string :type
            t.boolean :active , default: false
            t.integer :instance_count
            t.string :instance_url
            t.string :instance_token
            t.integer :profile_id
            t.text :url
            t.text :description
            t.text :report
            t.string :status
            t.text :statistics
            t.integer :owner_id

            t.timestamps
        end
    end
end
