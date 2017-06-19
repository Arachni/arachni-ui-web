class AddAuditNestedCookiesToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :audit_nested_cookies, :boolean
  end
end
