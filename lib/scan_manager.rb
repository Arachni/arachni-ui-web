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

require 'arachni/rpc/server/instance'

class ScanManager
    include Singleton

    def self.monitor
        instance.monitor
    end

    def monitor
        return if Rails.env == 'test'
        @timer ||= ::EM.add_periodic_timer( HardSettings.scan_refresh_rate / 1000 ) do
            keep_schedule
            refresh
        end
    end

    def self.process( scan )
        instance.process scan
    end

    def process( scan )
        return if Rails.env == 'test'

        # If the scan has a status then it's not the first time that it's been
        # saved so bail out to avoid an inf loop.
        return if scan.status

        if scan.schedule.start_at?
            scan.status = :scheduled
            scan.save

            return
        end

        start_scan scan

        true
    end

    private

    def keep_schedule
        Rails.logger.info "#{self.class}##{__method__}"

        Schedule.due.each do |schedule|
            start_scan schedule.scans.last
        end
    end

    def start_scan( scan )
        scan.status = :initializing
        scan.save

        Thread.new do
            begin
                if scan.type == :direct
                    scan.instance_url, scan.instance_token = spawn_instance
                    scan.start
                else
                    owner = "WebUI v#{ArachniWebui::Application::VERSION}"

                    if scan.type == :remote && scan.load_balance?
                        scan.dispatcher = scan.owner.available_dispatchers.preferred
                        scan.save
                    end

                    # If there are no Dispatcher either because they disappeared
                    # before we could select one to load balance or the assigned
                    # Dispatcher is no longer alive, put the scan in schedule
                    # limbo and let the user decide how to proceed.
                    if !scan.dispatcher || !scan.dispatcher.alive?
                        scan.status            = :schedule
                        scan.schedule.start_at = nil
                        scan.dispatcher        = nil
                        scan.save

                        scan.notify(
                            action: :dispatcher_disappeared,
                            text:   'Please select a different Dispatcher or' +
                                ' distribution type.'
                        )
                        next
                    end

                    scan.dispatcher.client.dispatch( owner, {}, scan.grid? ) do |instance_info|
                        scan.instance_url   = instance_info['url']
                        scan.instance_token = instance_info['token']
                        scan.save

                        scan.start
                    end
                end
            rescue => e
                ap e
                ap e.backtrace
            end
        end

        true
    end

    def refresh
        Rails.logger.info "#{self.class}##{__method__}"

        ::EM::Iterator.new( Scan.active ).each do |scan, iter|
            scan.refresh { iter.next } rescue iter.next
        end
    end

    def spawn_instance
        # Global address to bind to.
        Arachni::Options.rpc_address = 'localhost'

        # Set some RPC server info for the Instance
        token = Arachni::Utilities.generate_token
        port  = Arachni::Utilities.available_port

        # Prevents "Connection was reset" errors on the client-side.
        # (i.e. Let Rails send the response back before forking EM.)
        sleep 1

        # Clear all connections so the child we're about to spawn won't
        # take any of them with it.
        ::ActiveRecord::Base.clear_all_connections!

        Process.detach ::EM.fork_reactor {
            # redirect the Instance's RPC server's output to /dev/null
            $stdout.reopen( '/dev/null', 'w' )
            $stderr.reopen( '/dev/null', 'w' )

            Arachni::Options.rpc_port = port
            Arachni::RPC::Server::Instance.new( Arachni::Options.instance, token )
        }

        # Wait for the instance server to become active.
        sleep 1

        # Re-establish the connection to the DB.
        ::ActiveRecord::Base.establish_connection

        [ "#{Arachni::Options.rpc_address}:#{port}", token ]
    end

end
