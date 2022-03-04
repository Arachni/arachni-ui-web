=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class Comment < ActiveRecord::Base
    belongs_to :commentable, polymorphic: true
    belongs_to :user

    validates :text, presence: true
    validate :validate_text

    def commentable
        commentable_type.classify.constantize.find( commentable_id )
    end

    private

    def validate_text
        return if ActionController::Base.helpers.strip_tags( text ) == text
        errors.add :text, 'cannot contain HTML, please use Markdown instead'
    end

end
