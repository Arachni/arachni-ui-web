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
            if scan.type == :direct
                scan.instance_url, scan.instance_token = spawn_instance
                scan.start
            else
                owner = "WebUI v#{ArachniWebui::Application::VERSION}"
                scan.dispatcher.client.dispatch( owner ) do |instance_info|
                    scan.instance_url   = instance_info['url']
                    scan.instance_token = instance_info['token']
                    scan.save

                    scan.start
                end
            end
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
