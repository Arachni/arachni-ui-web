class RenameSettingsModulesToChecks < ActiveRecord::Migration[4.2]
    def change
        rename_column :settings, :profile_allowed_modules, :profile_allowed_checks
    end
end
