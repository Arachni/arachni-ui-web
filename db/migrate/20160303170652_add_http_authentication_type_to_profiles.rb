class AddHttpAuthenticationTypeToProfiles < ActiveRecord::Migration[4.2]
    def change
        add_column :profiles, :http_authentication_type, :string
    end
end
