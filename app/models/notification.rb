class Notification < ActiveRecord::Base
    belongs_to :user

    attr_accessible :model, :actor, :user, :action, :actor_id, :model_id,
                    :model_type, :text, :user_id

    def self.mark_read
        update_all( { read: true }, { read: false } )
    end

    def self.unread
        where( read: false )
    end

    def read?
        read
    end

    def unread?
        !read?
    end

    def user=( u )
        return if !u
        self.user_id = u.id
    end

    def user
        return if !user_id
        User.find( user_id )
    end

    def actor=( u )
        return if !u
        self.actor_id = u.id
    end

    def actor
        return if !actor_id
        User.find( actor_id )
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
                "#{model.class} <em>#{model}</em>"
                end.join( ' of ' )
            else
                "(Now deleted) #{model_type} ##{model_id}"
            end

        s << " #{action_description}"
        s << " by #{actor}" if actor
        s
    end

end
