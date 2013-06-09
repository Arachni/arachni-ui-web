class AddFingerprintingToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :no_fingerprinting, :boolean
    add_column :profiles, :platforms, :text
  end
end
