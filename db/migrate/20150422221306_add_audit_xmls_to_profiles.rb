class AddAuditXmlsToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :audit_xmls, :boolean
  end
end
