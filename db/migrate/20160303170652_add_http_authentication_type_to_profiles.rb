class AddHttpAuthenticationTypeToProfiles < ActiveRecord::Migration
    def change
        add_column :profiles, :http_authentication_type, :string
    end
end
