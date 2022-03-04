class AddHttpResponseMaxSizeToProfiles < ActiveRecord::Migration[4.2]
    def change
        add_column :profiles, :http_response_max_size, :integer
    end
end
