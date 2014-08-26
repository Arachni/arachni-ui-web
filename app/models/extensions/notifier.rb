=begin
    Copyright 2013-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

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
