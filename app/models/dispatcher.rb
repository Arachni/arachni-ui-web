=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

require 'arachni/rpc/client'

class Dispatcher < ActiveRecord::Base
    include Extensions::Notifier

    has_many :scans

    has_and_belongs_to_many :users
    belongs_to :owner, class_name: 'User', foreign_key: :owner_id

    validates_presence_of :address

    validates_presence_of :port
    validates_numericality_of :port

    validates_uniqueness_of :address, scope: :port, case_sensitive: false

    validate :server_reachability
    validate :validate_description

    before_save    :add_owner_to_subscribers
    before_destroy :delete_client

    after_create  DispatcherManager.instance

    serialize :statistics, Hash

    scope :alive,       -> { where alive: true }
    scope :unreachable, -> { where alive: false }
    scope :global,      -> { where global: true }

    # Exclude sensitive info.
    def to_json( options = {} )
        return super if options[:safe]

        stats = statistics.dup
        statistics['running_jobs'].each { |j| j.delete 'token' }
        super( options )
    ensure
        self.statistics = stats
    end

    def self.describe_notification( action )
        case action
            when :destroy
                'was deleted'
            when :create
                'created'
            when :update
                'was updated'
            when :share
                'was shared with you'
            when :make_default
                'was set as the system default'
            else
                action.to_s
        end
    end

    def self.preferred
        alive.order( 'score ASC' ).first
    end

    def family
        [self]
    end

    def self.default
        self.where( default: true ).first
    end

    def self.unmake_default
        update_all default: false
    end

    def make_default
        self.class.unmake_default
        self.default = true
        self.save
    end

    def default?
        !!self.default
    end

    def self.find_by_url( url )
        address, port = *url.split( ':' )
        where( address: address, port: port ).first
    end

    def self.grid_members
        all.select { |d| d.grid_member? }
    end

    def self.non_grid_members
        all.reject { |d| d.grid_member? }
    end

    def self.has_grid?
        alive.map { |d| d.grid_member? }.include? true
    end

    def self.recent( limit = 5 )
        limit( limit ).order( "id desc" )
    end

    def to_label
        str = to_s
        str << " | #{jobs.size} scans" if jobs.any?
        str << " | Pipe: #{pipe_id}" if !pipe_id.to_s.empty?
        str
    end

    def to_s
        str = ''
        str << "#{name} | " if !name.to_s.empty?
        str << "#{url}"
    end

    def has_scheduled_scans?
        scans.scheduled.any?
    end

    def grid_member?
        (statistics['neighbours'] || []).any?
    end

    def alive?
        !!alive
    end
    alias :reachable? :alive?

    def statistics
        { 'node' => {} }.merge( super || {})
    end

    def consumed_pids
        statistics['consumed_pids'] || []
    end

    def name
        statistics['node']['nickname']
    end

    def pipe_id
        statistics['node']['pipe_id']
    end

    def neighbours
        (statistics['neighbours'] || []).map { |n| Dispatcher.find_by_url( n ) }
    end

    def weight
        statistics['node']['weight']
    end

    def jobs
        statistics['running_jobs'] || []
    end

    def finished_jobs
        statistics['finished_jobs'] || []
    end

    def node_info
        statistics['node']
    end

    def snapshots
        statistics['snapshots'] || []
    end

    def snapshot_filenames
        snapshots.map { |s| File.basename s }
    end

    def url
        "#{address}:#{port}"
    end

    def client
        client_synchronize do
            client_factory[client_key] ||=
                Arachni::RPC::Client::Dispatcher.new(
                    Arachni::Options.instance, url
                )
        end
    end

    def refresh( &block )
        Rails.logger.info "#{self.class}##{__method__}: #{self.id}"
        client.statistics do |stats|
            if stats.rpc_exception?
                if alive?
                    self.alive = false
                    save( validate: false )
                end

                delete_client
                block.call if block_given?
                next
            end

            # Skip validation because #server_reachability is not necessary.
            self.alive      = true
            self.statistics = stats
            self.score      = stats['node']['score']
            save( validate: false )

            stats['neighbours'].each do |neighbour|
                naddress, nport = neighbour.split( ':' )
                next if self.class.where( address: naddress, port: nport ).any?
                self.class.create( address: naddress, port: nport, owner_id: owner_id,
                                   description: "Automatically added as a neighbour of '#{url}'." )
            end

            block.call if block_given?
        end
    end

    private

    def client_factory
        @@dispatchers ||= {}
    end

    def client_synchronize( &block )
        (@@client_mutex ||= Mutex.new).synchronize(&block)
    end

    def client_key
        url.hash
    end

    def delete_client
        client_synchronize do
            i = client_factory.delete( client_key )
            i.close if i
        end
    end

    def server_reachability
        return if ApplicationHelper.host_reachable?( address, port )

        err = 'does not point to a running server'
        errors.add :address, err
        errors.add :port, err
    end

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

    def add_owner_to_subscribers
        return if !owner
        self.user_ids |= [owner.id]
        true
    end

end
