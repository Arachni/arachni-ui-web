class ScanManager
    include Singleton

    def self.monitor
        instance.monitor
    end

    def monitor
        @timer ||= ::EM.add_periodic_timer( 5 ){ refresh }
    end

    def after_create( scan )
        # If the scan has a status then it's not the first time that it's been
        # saved so bail out to avoid an inf loop.
        return if scan.status
        scan.status = :initializing
        scan.save

        Thread.new do
            url, token = case scan.type
                              when :direct
                                  spawn_instance
                              when :remote
                                  raise 'Not implemented'
                              when :grid
                                  raise 'Not implemented'
                          end

            scan.instance_url   = url
            scan.instance_token = token
            scan.save

            scan.start
        end

        true
    end

    private

    def refresh
        Rails.logger.info "#{self.class}##{__method__}"

        ::EM::Iterator.new( Scan.active ).each do |scan, iter|
            scan.refresh { iter.next } rescue iter.next
        end
    end

    def spawn_instance
        require 'arachni/rpc/server/instance'

        # Global address to bind to.
        Arachni::Options.rpc_address = 'localhost'

        # Set some RPC server info for the Instance
        token = Arachni::Utilities.generate_token
        port  = Arachni::Utilities.available_port

        # Prevents "Connection was reset" errors on the client-side.
        # (i.e. Let Rails send the response back before forking EM.)
        sleep 1

        Process.detach ::EM.fork_reactor {
            # redirect the Instance's RPC server's output to /dev/null
            #$stdout.reopen( '/dev/null', 'w' )
            #$stderr.reopen( '/dev/null', 'w' )

            Arachni::Options.rpc_port = port
            Arachni::RPC::Server::Instance.new( Arachni::Options.instance, token )
        }

        # Wait for the instance server to become active.
        sleep 1

        [ "#{Arachni::Options.rpc_address}:#{port}", token ]
    end

end
