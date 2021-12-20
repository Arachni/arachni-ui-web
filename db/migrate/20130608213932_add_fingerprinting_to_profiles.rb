class AddFingerprintingToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :no_fingerprinting, :boolean
    add_column :profiles, :platforms, :text
  end
end
