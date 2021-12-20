class AddAuditJsonsToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :audit_jsons, :boolean
  end
end
