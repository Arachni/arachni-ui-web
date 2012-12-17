class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :name
      t.text :url
      t.text :var
      t.boolean :verification
      t.float :cvssv2
      t.integer :cwe
      t.text :description
      t.string :elem
      t.string :method
      t.text :references
      t.text :remedy_code
      t.text :remedy_guidance
      t.string :severity
      t.string :digest
      t.integer :scan_id

      t.timestamps
    end
  end
end
