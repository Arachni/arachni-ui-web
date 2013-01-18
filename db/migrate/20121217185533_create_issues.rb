class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :name
      t.text :url

      t.text :vector_name # var

      t.float :cvssv2
      t.integer :cwe
      t.text :description

      t.string :vector_type # elem

      t.string :http_method # method

      t.text :tags
      t.text :headers

      t.text :signature # regexp
      t.text :seed # injected
      t.text :proof # regexp_match

      t.text :response_body # response

      t.boolean :requires_verification # verification

      t.text :audit_options # opts

      t.text :references
      t.text :remedy_code
      t.text :remedy_guidance
      t.string :severity
      t.string :digest

      t.boolean :false_positive, default: false

      t.boolean :verified, default: false
      t.datetime :verified_at
      t.text :verification_steps

      t.integer :verified_by
      t.integer :verification_steps_by

      t.integer :scan_id

      t.timestamps
    end
  end
end
