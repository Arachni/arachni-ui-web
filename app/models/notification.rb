=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class Notification < ActiveRecord::Base
    belongs_to :user
    belongs_to :actor, class_name: 'User', foreign_key: :actor_id

    scope :read,   -> { where read: true }
    scope :unread, -> { where read: false }

    before_save :add_identifier

    def self.mark_read
        update_all read: true
    end

    def unread?
        !read?
    end

    def model=( m )
        self.model_type = m.class.to_s
        self.model_id   = m.id
        m
    end

    def model
        model_class.find( model_id ) rescue nil
    end

    def model_class
        model_type.classify.constantize
    end

    def action
        super.to_sym
    end

    def action_description
        model_class.describe_notification action
    end

    def to_s
        s = if model
                model.family.reverse.map do |model|
                "#{model.class} #{model}"
                end.join( ' of ' )
            else
                "(Now deleted) #{model_type} ##{model_id}"
            end

        s << " #{action_description}"
        s << " by #{actor}" if actor
        s
    end

    def generate_identifier
        Digest::SHA2.hexdigest [model_type, model_id, action, text].join( ':' )
    end

    private

    def add_identifier
        self.identifier = generate_identifier
        true
    end
end
