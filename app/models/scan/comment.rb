class Scan::Comment < ActiveRecord::Base
    belongs_to :scan
    belongs_to :user
    attr_accessible :scan_id, :text, :user_id
end
