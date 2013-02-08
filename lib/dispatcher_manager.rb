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

class DispatcherManager
    include Singleton

    def self.monitor
        instance.monitor
    end

    def monitor
        @timer ||= ::EM.
            add_periodic_timer( Settings.dispatcher_refresh_rate / 1000 ){ refresh }
    end

    def after_create( dispatcher )
        # Avoid having this called multiple times for the same Dispatcher.
        return if dispatcher.statistics.any?
        dispatcher.refresh
    end

    private

    def refresh
        Rails.logger.info "#{self.class}##{__method__}"

        ::EM::Iterator.new( Dispatcher.all ).each do |dispatcher, iter|
            dispatcher.refresh { iter.next } rescue iter.next
        end
    end

end
