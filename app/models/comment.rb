=begin
    Copyright 2013-2014 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
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
