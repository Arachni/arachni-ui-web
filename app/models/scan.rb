require 'arachni/rpc/client'

class Scan < ActiveRecord::Base
    set_inheritance_column 'inheritance_column'

    belongs_to :dispatcher
    belongs_to :profile
    belongs_to :owner, class_name: 'User', foreign_key: :owner_id
    has_and_belongs_to_many :users

    has_many :issues,        dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy

    attr_accessible :url, :description, :type, :instance_count, :profile_id,
                    :user_ids, :dispatcher_id

    validates_presence_of :url
    validate :validate_url

    validates :type, inclusion: { in:      [:direct, :remote, :grid],
                                  message: "Please select a scan type" }
    validate :validate_type

    validate :validate_instance_count

    # The manager will start the scans when they are created and monitor and
    # update their progress and other details at regular intervals.
    after_create ScanManager.instance

    serialize :report,     Arachni::AuditStore
    serialize :statistics, Hash

    SENSITIVE = [ :instance_token ]

    # Exclude SENSITIVE info.
    def to_json( options = {} )
        options[:except] ||= SENSITIVE
        super( options )
    end

    def self.recent( limit = 5 )
        light.find( :all, order: "id desc", limit: limit )
    end

    def to_s
        s = "#{url} | #{profile} profile, #{issue_count} issues"
        s << " (#{progress}%)" if !finished?
        s << '.'
    end

    def self.active
        where( active: true )
    end

    def self.inactive
        where( active: false )
    end

    def self.finished
        where( "status = 'completed' OR status = 'aborted' OR status = 'error'" )
    end

    def self.light
        select( column_names - %w(report) )
    end

    def parsed_url
        Arachni::URI( url )
    end

    def sorted_issues
        sorted_by_severity = {
            Arachni::Issue::Severity::HIGH          => [],
            Arachni::Issue::Severity::MEDIUM        => [],
            Arachni::Issue::Severity::LOW           => [],
            Arachni::Issue::Severity::INFORMATIONAL => []
        }
        issues.each do |i|
            sorted_by_severity[i.severity] << i
        end

        sorted_by_severity.values.flatten
    end

    def active?
        active
    end

    def finished?
        completed? || aborted? || error?
    end

    def running?
        active? && !initializing?
    end

    def cleaning_up?
        !active? && !finished?
    end

    def completed?
        status == :completed
    end

    def initializing?
        status == :initializing
    end

    def paused?
        status == :pausing || status == :paused
    end

    def aborted?
        status == :aborted
    end

    def error?
        status == :error
    end

    def grid?
        type == :grid
    end

    def issue_count
        issues.size
    end

    def issue_digests
        Issue.digests_for_scan( self ).map { |i| i.digest }
    end

    def eta
        statistics['eta']
    end

    def runtime
        statistics['time']
    end

    def progress
        statistics['progress']
    end

    def current_page
        statistics['current_page']
    end

    def sitemap_size
        statistics['sitemap_size']
    end

    def self.report=( r )
        super( r )
        push_arachni_issues( r.issues )
        r
    end

    def type
        super.to_sym if super
    end

    def status
        super.to_sym if super
    end

    def instance
        @instance ||=
            Arachni::RPC::Client::Instance.new( Arachni::Options.instance,
                                                instance_url, instance_token )
    end

    def abort
        self.status = :aborting
        self.active = false
        save

        instance.service.abort_and_report :auditstore  do |auditstore|
            if !auditstore.rpc_exception?
                self.report = auditstore
                save
                instance.service.shutdown {}
            end

            self.status = :aborted
            finish
        end
        true
    end

    def pause
        self.status = :pausing
        save

        instance.framework.pause {}
    end

    def resume
        self.status = :resuming
        save

        instance.framework.resume {}
    end

    def spawns
        instance_count - 1
    end

    def start
        self.status = :starting
        self.active = true
        save

        instance.service.scan( profile.to_rpc_options.merge(
            url:    url,
            spawns: spawns,
            grid:   grid?
        )) { refresh }
    end

    def refresh( &block )
        Rails.logger.info "#{self.class}##{__method__}: #{self.id}"

        instance.service.
            progress( with:    [ :instances, :native_issues,
                                 errors: error_messages.to_s.lines.count ],
                      without: [ issues: issue_digests ] ) do |progress_data|

            if progress_data.rpc_exception?
                self.status = :error
                self.active = false
                save
                next
            end

            begin
                self.active     = true
                self.status     = progress_data['status']
                self.statistics = progress_data['stats']

                if progress_data['errors'] && !(msgs = progress_data['errors'].join( "\n" )).empty?
                    self.error_messages += "\n" + progress_data['errors'].join( "\n" )
                end

                push_arachni_issues( progress_data['issues'] )

                # If the scan has completed grab the report and mark it as such.
                if progress_data['busy']
                    block.call if block_given?
                else
                    finish

                    # Grab the report, we're all done. :)
                    update_report do
                        # Set as completed in order for this scan to be skipped by
                        # the next ScanManager#refresh_scans iteration.
                        self.status = :completed
                        save

                        block.call if block_given?
                    end
                end

                save
            rescue => e
                ap e
                ap e.backtrace
            end
        end
    end

    private

    def push_arachni_issues( a_issues )
        [a_issues].compact.flatten.each do |i|
            next if issue_digests.include? i.digest

            issue_data = i.to_h.reject { |k, _| !Issue.column_names.include?( k ) }
            issue_data['digest'] = i.digest
            issues.create issue_data
        end
    end

    def update_report( &block )
        # Grab the report and save the scan, we're all done now. :)
        instance.service.auditstore do |auditstore|
            self.report = auditstore
            save
            block.call if block_given?
        end
    end

    def finish
        self.active      = false
        self.finished_at = Time.now
        save
    end

    def validate_url
        if url.to_s.empty? ||
            (purl = Arachni::URI( url )).to_s.empty? || !purl.absolute?
            errors.add :url, "not a valid absolute URL"
        end
    end

    def validate_type
        if [:grid, :remote].include?( type ) && !dispatcher
            errors.add :type, "#{type.to_s.capitalize} scan is not available " +
                "as there are no suitable Dispatchers available"
        end
    end

    def validate_instance_count
        if grid? && instance_count <= 1
            errors.add :instance_count, 'must be more than 1 for Grid scans'
        end

        if instance_count < 1
            errors.add :instance_count, 'must be at least 1'
        end
    end

end
