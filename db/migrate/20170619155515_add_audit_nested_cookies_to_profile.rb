class AddAuditNestedCookiesToProfile < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :audit_nested_cookies, :boolean
  end
end
