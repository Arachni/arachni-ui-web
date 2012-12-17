require 'arachni/rpc/client'

class Scan < ActiveRecord::Base
    set_inheritance_column 'inheritance_column'

    belongs_to :profile
    belongs_to :owner, class_name: 'User', foreign_key: :owner_id
    has_and_belongs_to_many :users

    attr_accessible :url, :type, :instance_count, :profile_id, :user_ids

    validates_presence_of :url
    validate :validate_url

    validates :type, inclusion: { in:      [:direct, :remote, :grid],
                                  message: "Please select a scan type" }

    # The manager will start the scans when they are saved for the first time
    # and will monitor and update their progress and other details at regular
    # intervals.
    after_save     ScanManager.instance

    serialize :report,          Arachni::AuditStore
    serialize :issue_summaries, Array
    serialize :statistics,      Hash

    def self.active
        where( active: true )
    end

    def self.finished
        where( active: false )
    end

    def self.light
        select( column_names - %w(report issue_summaries) )
    end

    def parsed_url
        Arachni::URI( url )
    end

    def active?
        active
    end

    def finished?
        !active
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

    def issues
        issue_summaries.empty? ? report.issues : issue_summaries
    end

    def issues=( i )
        self.issue_summaries = i
        self.issue_count = i.size
        i
    end

    def self.report=( r )
        super( r )
        self.issue_count = r.issues.size

        # We've got the full report, no need for the issue summaries anymore.
        self.issue_summaries.clear

        r
    end

    def type
        super.to_sym if super
    end

    def status
        super.to_sym if super
    end

    def completed?
        status == :completed
    end

    def paused?
        status == :pausing || status == :paused
    end

    def aborted?
        status == :aborted
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

            aborted
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

    def start
        self.status = :starting
        self.active = true
        save

        instance.service.scan( profile.to_rpc_options.merge(
            url:    url,
            spawns: instance_count - 1
        )) { refresh }
    end

    def refresh( &block )
        instance.service.progress( with: :native_issues ) do |progress_data|
            begin
                self.statistics = progress_data['stats']
                self.issues     = progress_data['issues']
                self.status     = progress_data['status']

                # If the scan has completed grab the report and mark it as such.
                if !progress_data['busy']

                    # Set as completed in order for this scan to be skipped by
                    # the next ScanManager#refresh_scans iteration.
                    completed

                    # Grab the report, we're all done. :)
                    update_report( &block )
                else
                    block.call if block_given?
                end

                save
            rescue => e
                ap e
                ap e.backtrace
            end
        end
    end

    private

    def update_report( &block )
        # Grab the report and save the scan, we're all done now. :)
        instance.service.auditstore do |auditstore|
            self.report = auditstore
            save
            block.call if block_given?
        end
    end

    def completed
        self.status = :completed
        self.active = false
        save
    end

    def aborted
        self.status = :aborted
        self.active = false
        save
    end

    def validate_url
        if url.to_s.empty? ||
            (purl = Arachni::URI( url )).to_s.empty? || !purl.absolute?
            errors.add :url, "not a valid absolute URL"
        end
    end


end
