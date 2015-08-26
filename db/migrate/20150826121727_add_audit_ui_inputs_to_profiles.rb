class AddAuditUiInputsToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :audit_ui_forms, :boolean
    add_column :profiles, :audit_ui_inputs, :boolean
  end
end
