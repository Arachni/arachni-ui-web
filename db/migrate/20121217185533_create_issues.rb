class CreateIssues < ActiveRecord::Migration[4.2]
  def change
    create_table :issues do |t|
      t.string :name
      t.binary :url

      t.binary :vector_name # var

      t.float :cvssv2
      t.integer :cwe
      t.text :description

      t.string :vector_type # elem

      t.string :http_method # method

      t.text :tags
      t.text :headers

      t.binary :signature # regexp
      t.binary :seed # injected
      t.binary :proof # regexp_match

      t.binary :response_body # response

      t.boolean :requires_verification # verification

      t.binary :audit_options # opts

      t.text :references
      t.text :remedy_code
      t.text :remedy_guidance
      t.text :remarks
      t.string :severity
      t.string :digest

      t.boolean :false_positive, default: false

      t.boolean :verified, default: false
      t.text :verification_steps
      t.text :remediation_steps

      t.boolean :fixed, default: false

      t.integer :scan_id

      t.timestamps
    end
  end
end
