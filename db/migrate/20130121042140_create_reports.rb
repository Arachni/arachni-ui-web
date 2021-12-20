class CreateReports < ActiveRecord::Migration[4.2]
  def change
    create_table :reports do |t|
      t.binary :object
      t.text :sitemap
      t.integer :scan_id

      t.timestamps
    end
  end
end
