class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.text :object
      t.text :sitemap
      t.integer :scan_id

      t.timestamps
    end
  end
end
