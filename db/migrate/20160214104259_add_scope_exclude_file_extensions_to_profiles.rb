class AddScopeExcludeFileExtensionsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :scope_exclude_file_extensions, :text
  end
end
