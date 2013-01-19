class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
    belongs_to :user

    validates :text, presence: true

    validate :validate_text

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

    private

    def validate_text
        return if ActionController::Base.helpers.strip_tags( text ) == text
        errors.add :text, 'cannot contain HTML, please use Markdown instead'
    end

end
