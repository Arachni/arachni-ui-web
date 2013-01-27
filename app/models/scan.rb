require 'arachni/rpc/client'

class Scan < ActiveRecord::Base
    include Extensions::Notifier

    set_inheritance_column 'inheritance_column'

    has_and_belongs_to_many :users

    belongs_to :dispatcher
    belongs_to :profile
    belongs_to :owner,  class_name: 'User', foreign_key: :owner_id
    belongs_to :root,   class_name: 'Scan'

    has_one :report

    has_many :issues,        dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :revisions, class_name: 'Scan', foreign_key: :root_id

    attr_accessible :url, :description, :type, :instance_count, :profile_id,
                    :user_ids, :dispatcher_id, :restrict_to_revision_sitemaps,
                    :extend_from_revision_sitemaps

    validates_presence_of :url
    validate :validate_url

    validates :type, inclusion: { in:      [:direct, :remote, :grid],
                                  message: "Please select a scan type" }
    validate :validate_type

    validate :validate_instance_count
    validate :validate_description

    # The manager will start the scans when they are created and monitor and
    # update their progress and other details at regular intervals.
    after_create ScanManager.instance

    serialize :statistics,    Hash
    serialize :issue_digests, Array

    SENSITIVE = [ :instance_token ]

    # Exclude SENSITIVE info.
    def to_json( options = {} )
        options[:except] ||= SENSITIVE
        super( options )
    end

    def self.recent( limit = 5 )
        light.find( :all, order: "id desc", limit: limit )
    end

    def subscribers
        users | [owner]
    end

    def family
        [self]
    end

    def to_s
        s = "#{url} (#{profile} profile)"
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

    def issues
        overview? ? @overview.issues : super
    end

    def sitemap
        overview? ? @overview.sitemap : super
    end

    def issue_digests
        overview? ? @overview.issue_digests : super
    end

    def issue_count
        overview? ? @overview.issue_count : issues.size
    end

    def overview?
        !!@overview
    end

    def act_as_overview
        @overview = ScanOverview.new( self )
        self
    end

    def overview
        ScanOverview.new( self )
    end

    def act_as_revision
        @overview = nil
        self
    end

    def previous_revisions
        return if root?
        root_revision.revisions.where( 'id < ?', id )
    end

    def previous_revisions_with_root
        return if root?
        Scan.where( 'id = ? OR (root_id = ? AND id < ?)', root_revision.id,
                    root_revision.id, id ).
            order( 'id asc' )
    end

    def next_revisions
        return if root?
        root_revision.revisions.where( 'id > ?', id )
    end

    def next_revisions_with_root
        return if root?
        Scan.where( 'id = ? OR (root_id = ? AND id > ?)', root_revision.id,
                    root_revision.id, id ).
            order( 'id asc' )
    end

    def revision_index
        revisions_with_root.index( self )
    end

    def revisions
        super.order( 'id asc' )
    end

    def revisions_with_root
        Scan.where( 'id = ? OR root_id = ?', root_revision.id, root_revision.id ).
            order( 'id asc' )
    end

    def revisions_issues
        Issue.where( scan_id: [revisions_with_root.select( :id ).map( &:id )] )
    end

    def revisions_sitemap
        return if root?

        Report.select( [:sitemap, :scan_id] ).
            where( scan_id: [revisions_with_root.select( :id ).map( &:id ) - [id]] ).
            map( &:sitemap ).flatten.uniq
    end

    def revisions_issue_count
        i = issues.count
        revisions.light.each { |r| i += r.issues.count }
        i
    end

    def revisions_issue_digests
        return issue_digests if root?
        revisions_with_root.light.map( &:issue_digests ).flatten
    end

    def has_revisions?
        revisions.any?
    end

    def root_revision
        root? ? self : root
    end

    def revision_member?
        has_revisions? || revision?
    end

    def root?
        !root
    end

    def revision?
        !root?
    end

    def parsed_url
        Arachni::URI( url )
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
                create_report( auditstore )
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

    def self.describe_notification( action )
        case action
            when :completed
                action
            when :error
                'encountered a fatal error and stopped'
            when :destroy
                'was deleted'
            when :abort
                'was aborted'
            when :pause, :resume
                "was #{action}d"
            when :create
                'started'
            when :commented
                'has a new comment'
            when :share
                'was shared with you'
            when :repeat
                'was repeated'
            else
                action.to_s
        end
    end

    def start
        self.status = :starting
        self.active = true
        save

        sitemap_opts = {}

        if revision?
            if extend_from_revision_sitemaps?
                sitemap_opts[:extend_paths] = revisions_sitemap
            elsif restrict_to_revision_sitemaps?
                sitemap_opts[:restrict_paths] = revisions_sitemap
            end
        end

        instance.service.scan( profile.to_rpc_options.merge(
            url:    url,
            spawns: spawns,
            grid:   grid?
        ).merge( sitemap_opts )) { refresh }

        self
    rescue => e
        ap e
        ap e.backtrace
    end

    def share( user_id_list )
        user_id_list |= [root_revision.owner.id] if root_revision.owner
        user_id_list = user_id_list.flatten.reject { |i| i.to_s.empty? }.map( &:to_i )

        revisions_with_root.each do |rev|
            rev.update_attribute( :user_ids, user_id_list )
        end
    end

    def new_revision( opts = {} )
        new = root_revision.dup

        new.root   = self
        new.active = nil
        new.status = nil
        new.report = nil
        new.finished_at    = nil
        new.statistics     = {}
        new.issue_digests  = []
        new.error_messages = ''

        new.owner_id = self.owner_id
        new.user_ids = self.user_ids

        new.save
        new
    end

    def repeat( opts = {} )
        return false if !update_attributes( opts )

        ScanManager.instance.after_create( self )
        true
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

                notify action: self.status

                next
            end

            begin
                self.active     = true
                self.status     = progress_data['status']
                self.statistics = progress_data['stats']

                if progress_data['errors'] && !(msgs = progress_data['errors'].join( "\n" )).empty?
                    self.error_messages += "\n" + progress_data['errors'].join( "\n" )
                end

                push_framework_issues( progress_data['issues'] )

                # If the scan has completed grab the report and mark it as such.
                if progress_data['busy']
                    block.call if block_given?
                else
                    finish

                    # Grab the report, we're all done. :)
                    save_report_and_shutdown do
                        # Set as completed in order for this scan to be skipped by
                        # the next ScanManager#refresh_scans iteration.
                        self.status = :completed
                        save

                        if revision?
                            previous_issues = Issue.
                                where( scan_id: previous_revisions_with_root.pluck( :id ), fixed: false ).
                                where( 'digest NOT IN (?)', issue_digests )

                            previous_issues.each do |i|
                                i.notify action: :fixed,
                                         text: "Marked as fixed as it did not " +
                                                 "appear in Revision ##{revision_index}."
                            end

                            # Mark issues that didn't appear in this scan as fixed.
                            previous_issues.update_all( fixed: true )
                        end

                        notify action: self.status

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

    def push_framework_issues( a_issues )
        if revision?
            previous_issues = Issue.
                where( scan_id: previous_revisions_with_root.pluck( :id ) )
        end

        [a_issues].flatten.compact.each do |i|
            skip = revisions_issue_digests.include?( i.digest )

            if !issue_digests.include?( i.digest )
                issue_digests << i.digest
                save
            end

            next if skip

            if revision?
                # Mark issue as not fixed for all revisions since we came across it.
                previous_issues.update_all( { fixed: false }, { digest: i.digest } )
            end

            issues.create_from_framework_issue i
        end
    end

    def update_from_framework_issues( a_issues )
        [a_issues].flatten.compact.each do |i|
            issues.update_from_framework_issue( i, [:remarks, :requires_verification] )
        end
    end

    def save_report_and_shutdown( &block )
        # Grab the report and save the scan, we're all done now. :)
        instance.service.abort_and_report :auditstore do |auditstore|
            create_report( auditstore )
            instance.service.shutdown {}

            block.call if block_given?
        end
    end

    def create_report( auditstore )
        begin
            self.report = Report.create( object: auditstore, scan_id: id )
            save

            push_framework_issues( auditstore.issues )
            update_from_framework_issues( auditstore.issues )

            auditstore
        rescue => e
            ap e
            ap e.backtrace
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

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

end
