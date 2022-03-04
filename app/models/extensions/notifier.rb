=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module Extensions
module Notifier
    extend ActiveSupport::Concern

    def self.describe_notification( action )
    end

    #
    # @return   [Array<User>]   Users to notify.
    #
    # @abstract
    #
    def subscribers
        users
    end

    def family
        [self]
    end

    #
    # Notifies {#subscribers} about an +action+ by +actor+ which affected {self}.
    #
    # @param    [Hash]  opts
    # @option opts [#to_s] :action  Action to notify about.
    # @option opts [User]   :actor  The {User} who performed the action.
    #
    def notify( opts = {} )
        subscribers.each do |subscriber|
            Notification.create(
                actor:  opts[:actor],
                model:  self,
                user:   subscriber,
                action: opts[:action].to_s,
                text:   opts[:text]
            )
        end
    end
end
end
