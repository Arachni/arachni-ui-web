class AddHttpResponseMaxSizeToProfiles < ActiveRecord::Migration
    def change
        add_column :profiles, :http_response_max_size, :integer
    end
end
