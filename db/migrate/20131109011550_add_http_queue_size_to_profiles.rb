class AddHttpQueueSizeToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :http_queue_size, :integer, default: Arachni::Options.http_queue_size
  end
end
