class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
    belongs_to :user

    attr_accessible :text, :user_id

    def subscribers
        commentable.subscribers
    end

    def family
        [scan, self]
    end

    def commentable
        commentable_type.classify.constantize.find( commentable_id )
    end
end
