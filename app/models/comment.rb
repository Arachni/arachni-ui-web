class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
    belongs_to :user

    attr_accessible :text, :user_id
end
