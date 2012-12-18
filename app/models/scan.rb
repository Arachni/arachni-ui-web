require 'arachni/rpc/client'

class Scan < ActiveRecord::Base
    set_inheritance_column 'inheritance_column'

    belongs_to :profile
    belongs_to :owner, class_name: 'User', foreign_key: :owner_id
    has_and_belongs_to_many :users

    has_many :issues,   dependent: :destroy
    has_many :comments, dependent: :destroy

    attr_accessible :url, :description, :type, :instance_count, :profile_id,
                    :user_ids

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
    serialize :issue_digests,   Array
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
        !active
    end

    def issue_count
        issues.size
    end

    def issue_digests
        issues.map { |i| i.digest }
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
        instance.service.
            progress( with: :native_issues,
                      without: [ issues: [ issue_digests ] ] ) do |progress_data|
            next if progress_data.rpc_exception?

            begin
                self.statistics  = progress_data['stats']

                push_arachni_issues( progress_data['issues'] )

                self.status = progress_data['status']

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
