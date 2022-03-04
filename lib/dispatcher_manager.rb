=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class DispatcherManager
    include Singleton

    def self.monitor
        instance.monitor
    end

    def monitor
        return if Rails.env == 'test'
        @timer ||= Arachni::Reactor.global.
            at_interval( HardSettings.dispatcher_refresh_rate / 1000 ){ refresh }
    end

    def after_create( dispatcher )
        return if Rails.env == 'test'
        # Avoid having this called multiple times for the same Dispatcher.
        return if dispatcher.statistics['node'].any?

        dispatcher.refresh
    end

    private

    def refresh
        Rails.logger.info "#{self.class}##{__method__}"

        Arachni::Reactor.global.create_iterator( Dispatcher.all ).each do |dispatcher, iter|
            dispatcher.refresh { iter.next } rescue iter.next
        end
    end

end
