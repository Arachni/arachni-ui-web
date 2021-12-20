class AddHttpQueueSizeToProfiles < ActiveRecord::Migration[4.2]
  def change
    add_column :profiles, :http_queue_size, :integer, default: Arachni::Options.http.request_queue_size
  end
end
