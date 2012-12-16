class CreateScanTests < ActiveRecord::Migration
  def change
    create_table :scan_tests do |t|

      t.timestamps
    end
  end
end
