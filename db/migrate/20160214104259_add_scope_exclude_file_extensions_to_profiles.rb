class AddScopeExcludeFileExtensionsToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :scope_exclude_file_extensions, :text
  end
end
