class AddAuditJsonsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :audit_jsons, :boolean
  end
end
