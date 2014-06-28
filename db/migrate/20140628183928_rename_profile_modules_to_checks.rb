class RenameProfileModulesToChecks < ActiveRecord::Migration
    def change
        rename_column :profiles, :modules, :checks
    end
end
