class DispatcherManager
    include Singleton

    def self.monitor
        instance.monitor
    end

    def monitor
        @timer ||= ::EM.add_periodic_timer( 5 ){ refresh }
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
