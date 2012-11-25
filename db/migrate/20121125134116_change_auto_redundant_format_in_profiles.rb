class ChangeAutoRedundantFormatInProfiles < ActiveRecord::Migration
    def change
        change_column :profiles, :auto_redundant, :integer
    end
end
