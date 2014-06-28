class RenameSettingsModulesToChecks < ActiveRecord::Migration
    def change
        rename_column :settings, :profile_allowed_modules, :profile_allowed_checks
    end
end
