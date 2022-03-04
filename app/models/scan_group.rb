=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
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
