class GenerateNotificationIdentifiers < ActiveRecord::Migration
  def self.up
      Notification.all.find_each do |notification|
          Notification.update_all( { identifier: notification.generate_identifier },
                                   id: notification.id )
      end
  end
end
