class CreateScans < ActiveRecord::Migration[4.2]
    def change
        create_table :scans do |t|
            t.string :type
            t.boolean :active, default: false
            t.boolean :extend_from_revision_sitemaps
            t.boolean :restrict_to_revision_sitemaps
            t.integer :instance_count, default: 1
            t.integer :dispatcher_id
            t.string :instance_url
            t.string :instance_token
            t.integer :profile_id
            t.text :url
            t.text :description
            t.text :report
            t.string :status
            t.text :statistics
            t.text :issue_digests
            t.text :error_messages
            t.integer :owner_id
            t.datetime :finished_at

            t.integer :root_id

            t.timestamps
        end
    end
end
