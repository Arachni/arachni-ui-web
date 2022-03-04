=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

require 'arachni/rpc/server/instance'
require 'arachni/processes/instances'

class ScanManager
    include Singleton

    def self.monitor
        instance.monitor
    end

    def monitor
        return if Rails.env == 'test'
        @timer ||= Arachni::Reactor.global.at_interval( HardSettings.scan_refresh_rate / 1000 ) do
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

    def self.restore( scan )
        instance.restore scan
    end

    def restore( scan )
        if scan.dispatcher
            fail 'Dispatcher is not alive.' if !scan.dispatcher.alive?

            scan.dispatcher.client.dispatch( "WebUI v#{ArachniWebui::Application::VERSION}" ) do |info|
                scan.instance_url   = info['url']
                scan.instance_token = info['token']
                scan.save

                scan.restore
            end
        else
            instance = Arachni::Processes::Instances.spawn( fork: false )
            scan.instance_url   = instance.url
            scan.instance_token = instance.token
            instance.close

            scan.restore
        end
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

                    # For some reason we can't Process.fork from the WebUI.
                    instance = Arachni::Processes::Instances.spawn( fork: false )

                    scan.instance_url   = instance.url
                    scan.instance_token = instance.token

                    instance.close

                    Arachni::RPC::Client::Instance.when_ready scan.instance_url, scan.instance_token do
                        scan.start
                    end
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

        Arachni::Reactor.global.create_iterator( Scan.active, 10 ).each do |scan, iter|
            begin
                scan.refresh { iter.next }
            rescue => e
                ap e
                ap e.backtrace
                iter.next
            end
        end
    end

end
