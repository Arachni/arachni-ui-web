=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

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

module NotificationsHelper

    def notify( model, opts = {} )
        if model.respond_to?( :subscribers )
            model.subscribers.each do |subscriber|
                Notification.create(
                    actor:  current_user,
                    model:  model,
                    user:   subscriber,
                    action: opts[:action] || params[:action],
                    text:   opts[:text] || model.to_s
                )
            end
        else
            Notification.create(
                actor:  current_user,
                model:  model,
                action: opts[:action] || params[:action],
                text:   opts[:text] || model.to_s
            )
        end
    end

end
