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

class ScanGroup < ActiveRecord::Base
    belongs_to :owner, class_name: 'User', foreign_key: :owner_id
    has_and_belongs_to_many :scans
    has_and_belongs_to_many :users

    validates_presence_of :name
    validates_uniqueness_of :name, scope: :owner_id

    validates_presence_of :description

    validate :validate_description

    before_save :add_owner_to_subscribers

    def to_s
        name
    end

    private

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

    def add_owner_to_subscribers
        self.user_ids |= [owner.id]
        true
    end
end
