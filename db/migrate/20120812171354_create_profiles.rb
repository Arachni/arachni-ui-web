class CreateProfiles < ActiveRecord::Migration[4.2]
    def change
        create_table :profiles do |t|
            t.integer :owner_id
            t.boolean :global
            t.boolean :default
            t.string :name
            t.text :description
            t.text :redundant
            t.integer :depth_limit
            t.integer :link_count_limit
            t.integer :redirect_limit
            t.integer :http_req_limit
            t.boolean :audit_links
            t.boolean :audit_forms
            t.boolean :audit_cookies
            t.boolean :audit_headers
            t.text :modules
            t.text :authed_by
            t.string :proxy_host
            t.integer :proxy_port
            t.string :proxy_username
            t.text :proxy_password
            t.string :proxy_type
            t.text :cookies
            t.text :user_agent
            t.text :exclude
            t.text :exclude_pages
            t.text :exclude_cookies
            t.text :exclude_vectors
            t.text :include
            t.boolean :follow_subdomains
            t.text :plugins
            t.text :custom_headers
            t.text :restrict_paths
            t.text :extend_paths
            t.integer :max_slaves
            t.boolean :fuzz_methods
            t.boolean :audit_cookies_extensively
            t.boolean :exclude_binaries
            t.integer :auto_redundant
            t.boolean :https_only
            t.text :login_check_url
            t.text :login_check_pattern
            t.integer :http_timeout

            t.timestamps
        end
    end
end
