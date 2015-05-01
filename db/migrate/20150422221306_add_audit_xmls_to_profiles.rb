class AddAuditXmlsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :audit_xmls, :boolean
  end
end
