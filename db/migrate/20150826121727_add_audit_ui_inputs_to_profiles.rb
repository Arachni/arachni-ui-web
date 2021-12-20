class AddAuditUiInputsToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :audit_ui_forms, :boolean
    add_column :profiles, :audit_ui_inputs, :boolean
  end
end
