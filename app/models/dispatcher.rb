require 'arachni/rpc/client'

class Dispatcher < ActiveRecord::Base
    has_many :scans

    validates_presence_of :address

    validates_presence_of :port
    validates_numericality_of :port

    validates_uniqueness_of :address, scope: :port

    validate :server_reachability
    validate :validate_description

    attr_accessible :address, :port, :description

    after_create  DispatcherManager.instance

    serialize :statistics, Hash

    # Exclude sensitive info.
    def to_json( options = {} )
        return super if options[:safe]

        stats = statistics.dup
        statistics['running_jobs'].each { |j| j.delete 'token' }
        super( options )
    ensure
        self.statistics = stats
    end

    def self.alive
        where( alive: true )
    end

    def self.unreachable
        where( alive: false )
    end

    def family
        [self]
    end

    def self.find_by_url( url )
        find_by_address_and_port( *url.split( ':' ) )
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
        find( :all, order: "id desc", limit: limit )
    end

    def to_label
        str = to_s
        str << " | #{jobs.size} scans" if jobs.any?
        str << " | Pipe: #{pipe_id}" if !pipe_id.to_s.empty? && grid_member?
        str
    end

    def to_s
        str = ''
        str << "#{name} | " if !name.to_s.empty?
        str << "#{url}"
    end

    def grid_member?
        # If we are another Dispatcher's neighbour and that Dispatcher has
        # a different pipe-id than us then we're in a Grid.
        (self.class.alive - [self]).each do |d|
            next if d.pipe_id == pipe_id
            return true if d.neighbours.include?( self )
        end

        false
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

    def score
        statistics['node']['score']
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

    def url
        "#{address}:#{port}"
    end

    def client
        @client ||=
            Arachni::RPC::Client::Dispatcher.new( Arachni::Options.instance, url )
    end

    def refresh( &block )
        Rails.logger.info "#{self.class}##{__method__}: #{self.id}"

        client.stats do |stats|
            if stats.rpc_exception?
                if alive?
                    self.alive = false
                    save( validate: false )
                end

                block.call if block_given?
                next
            end

            self.alive      = true
            self.statistics = stats
            save

            stats['neighbours'].each do |neighbour|
                naddress, nport = neighbour.split( ':' )
                self.class.create( address: naddress, port: nport,
                                   description: "Automatically added as a neighbour of '#{url}'." )
            end

            block.call if block_given?
        end
    end

    def server_reachability
        if !ApplicationHelper.host_reachable?( address, port )
            err = 'does not point to a running server'
            errors.add :address, err
            errors.add :port, err
        end
    end

    private

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

end
