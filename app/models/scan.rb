=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

require 'arachni/rpc/client'

class Scan < ActiveRecord::Base
    include Extensions::Notifier

    self.inheritance_column = 'inheritance_column'

    TYPES = [:direct, :remote, :grid]

    has_and_belongs_to_many :users
    has_and_belongs_to_many :scan_groups

    belongs_to :dispatcher
    belongs_to :profile
    belongs_to :owner,  class_name: 'User', foreign_key: :owner_id
    belongs_to :root,   class_name: 'Scan'
    belongs_to :schedule, autosave: true

    has_one :report

    has_many :issues,        dependent: :destroy
    has_many :comments, as: :commentable, dependent: :destroy
    has_many :revisions, class_name: 'Scan', foreign_key: :root_id

    accepts_nested_attributes_for :schedule

    validates_associated :schedule

    validates_presence_of :url
    validate :validate_url

    validates :type, inclusion: { in:      TYPES,
                                  message: 'Please select a scan type' }
    validate :validate_type

    validate :validate_instance_count
    validate :validate_description

    before_save :add_owner_to_subscribers

    serialize :statistics,    Hash
    serialize :issue_digests, Array

    scope :roots,       -> { where root_id: nil }
    scope :active,      -> { where active: true }
    scope :scheduled,   -> { where status: 'scheduled' }
    scope :running,     -> { where status: %w(scanning) }
    scope :paused,      -> { where status: %w(paused pausing) }
    scope :inactive,    -> { where active: false }
    scope :finished,    -> { where 'finished_at IS NOT NULL' }
    scope :suspended,   -> { where 'suspended_at IS NOT NULL' }

    SENSITIVE = [ :instance_token ]

    # Exclude SENSITIVE info.
    def to_json( options = {} )
        options[:except] ||= SENSITIVE
        super( options )
    end

    def self.limit_exceeded?
        Settings.scan_global_limit && active.size >= Settings.scan_global_limit
    end

    def self.recent( limit = 5 )
        limit( limit ).order( "id desc" )
    end

    def family
        [self]
    end

    def to_s
        "#{url} (#{profile} profile)"
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
            map( &:sitemap_urls ).flatten.uniq
    end

    def revisions_issue_count
        revisions_issues.count
    end

    def revisions_issue_digests
        return issue_digests if root?
        revisions_with_root.map( &:issue_digests ).flatten
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

    def root_with_revisions?
        root? && has_revisions?
    end

    def parsed_url
        Arachni::URI( url )
    end

    def finished?
        !!finished_at
    end

    def running?
        active? && !initializing?
    end

    def starting?
        status == :starting
    end

    def cleaning_up?
        !active? && !finished? && !suspended?
    end

    def scheduled?
        status == :scheduled
    end

    def completed?
        status == :completed
    end

    def initializing?
        status == :initializing
    end

    def scanning?
        status == :scanning
    end

    def paused?
        status == :pausing || status == :paused
    end

    def aborted?
        status == :aborted || status == :aborting
    end

    def suspended?
        status == :suspended || status == :suspending
    end

    def error?
        status == :error
    end

    def grid?
        type == :grid
    end

    def cannot_locate_snapshot?
        !snapshot_path || !File.exist?( snapshot_path )
    end

    def any_scheduled?
        schedule.start_at? && (revisions.active.any? || revisions.scheduled.any?)
    end

    def any_recurring?
        schedule.recurring? && (revisions.active.any? || revisions.scheduled.any?)
    end

    def runtime
        statistics[:runtime].to_i
    end

    def current_page
        statistics[:current_page]
    end

    def sitemap_size
        statistics[:found_pages]
    end

    def messages
        statistics[:messages] || []
    end

    def statistics
        (h = super).empty? ? { http: {} } : h
    end

    def type
        super.to_sym if super
    end

    def status
        super.to_sym if super
    end

    def instance
        client_synchronize do
            client_factory[client_key] ||= Arachni::RPC::Client::Instance.new(
                Arachni::Options.instance, instance_url, instance_token
            )
        end
    end

    def abort
        self.status = :aborting
        self.active = false
        save

        instance.service.native_abort_and_report do |report|
            if report.rpc_exception?
                handle_error report
            else
                create_report( report )
            end

            instance.service.shutdown { delete_client }

            self.status = :aborted
            finish
        end

        true
    end

    def suspend
        fail 'Scan not scanning.' if !scanning?

        self.status = :suspending
        save

        instance.service.suspend do |r|
            next handle_error( r ) if r.rpc_exception?

            # Might take a while for the scan to finish suspending.
            probe_freq = 5

            Arachni::Reactor.global.delay( probe_freq ) do |task|
                instance.service.snapshot_path do |path|
                    next handle_error( path ) if path.rpc_exception?
                    next Arachni::Reactor.global.delay( probe_freq, &task ) if !path

                    self.snapshot_path = path
                    self.status        = :suspended
                    self.suspended_at  = Time.now
                    self.active        = false
                    self.statistics    = {}
                    save

                    instance.service.shutdown { delete_client }
                end
            end
        end
    end

    def restore
        self.status = :restoring
        self.active = true
        self.save

        instance.service.restore( snapshot_path ) do
            self.suspended_at  = nil
            self.snapshot_path = nil
            self.save
        end
    end

    def pause
        self.status = :pausing
        save

        instance.service.pause {}
    end

    def resume
        self.status = :resuming
        save

        instance.service.resume {}
    end

    def spawns
        instance_count - 1
    end

    def self.describe_notification( action )
        case action
            when :completed
                action
            when :error
                'could no longer be monitored due to a connection error.' +
                    'The Instance has probably encountered a fatal error and stopped.'
            when :destroy
                'was deleted'
            when :abort, :abort_all
                'was aborted'
            when :timed_out
                'timed out'
            when :restore
                'was restored'
            when :suspend, :suspend_all
                'was suspended'
            when :pause, :pause_all
                'was paused'
            when :resume, :resume_all
                'was resumed'
            when :create
                'started'
            when :schedule
                'scheduled'
            when :dispatcher_disappeared
                'has an unreachable or deleted Dispatcher'
            when :commented
                'has a new comment'
            when :share
                'was shared'
            when :repeat
                'was repeated'
            when :update_memberships
                'has updated group memberships'
            else
                action.to_s
        end
    end

    def delta_time
        Arachni::Utilities.seconds_to_hms( finished_at - started_at )
    end

    def start
        self.status     = :starting
        self.started_at = Time.now
        save

        options = profile.to_rpc_options.merge(
            url:    url,
            spawns: spawns,
            grid:   spawns > 1 ? grid? : nil
        )

        if revision?
            if extend_from_revision_sitemaps?
                options['scope']['extend_paths'] = revisions_sitemap
            elsif restrict_to_revision_sitemaps?
                options['scope']['restrict_paths'] = revisions_sitemap
            end
        end

        instance.service.scan( options ) do |r|
            if r.rpc_exception?
                handle_error( r )
                next
            end

            refresh
        end

        self
    rescue => e
        logger.error e.to_s
        logger.error e.backtrace.join("\n")
    end

    def share( user_id_list )
        user_id_list |= [root_revision.owner_id]
        user_id_list = user_id_list.flatten.
                            reject { |i| i.to_s.empty? }.map( &:to_i )

        revisions_with_root.each do |rev|
            rev.update_attribute( :user_ids, user_id_list )
        end
    end

    def update_memberships( group_id_list )
        group_id_list = group_id_list.flatten.
                            reject { |i| i.to_s.empty? }.map( &:to_i )

        revisions_with_root.each do |rev|
            rev.update_attribute( :scan_group_ids, group_id_list )
        end
    end

    def new_revision( opts = {} )
        new = root_revision.dup

        new.root   = self.root || self
        new.active = nil
        new.status = nil
        new.report = nil
        new.finished_at    = nil
        new.statistics     = {}
        new.issue_digests  = []
        new.error_messages = ''

        new.owner_id = self.owner_id
        new.user_ids = self.user_ids
        new.schedule = self.schedule
        new.scan_group_ids = self.scan_group_ids

        new.save
        new
    end

    def repeat( opts = {} )
        return false if !update_attributes( opts )

        ScanManager.process( self )
        true
    end

    def timed_out?
        schedule.stop_after && runtime >= schedule.stop_after
    end

    def refresh( &block )
        logger.info "#{self.class}##{__method__}: #{self.id}"

        instance.service.
            native_progress(
                with:    [ :instances, :issues,
                            errors: error_messages.to_s.lines.count ],
                without: [ issues: issue_digests ] ) do |progress_data|

            self.error_messages ||= ''

            # ap progress_data
            if progress_data.rpc_exception?
                handle_error( progress_data )
                next
            end

            begin
                self.active     = true
                self.status     = progress_data[:status]
                self.statistics = progress_data[:statistics].merge( messages: progress_data[:messages] )

                if progress_data[:errors] && progress_data[:errors].any?
                    self.error_messages ||= ''
                    self.error_messages  += "#{progress_data[:errors].join( "\n" )}\n"
                end
                save

                push_framework_issues( progress_data[:issues] )

                next if aborted? || suspended?

                if timed_out?

                    if schedule.stop_suspend?
                        if scanning?
                            notify action: :timed_out
                            suspend
                        end
                    else
                        notify action: :timed_out
                        abort
                    end

                    next
                end

                # If the scan has completed grab the report and mark it as such,
                # otherwise just call the block.
                if progress_data[:busy]
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
                                where( scan_id: previous_revisions_with_root.pluck( :id ), fixed: false )

                            if issue_digests.any?
                                previous_issues = previous_issues.
                                    where( 'digest NOT IN (?)', issue_digests )
                            end

                            previous_issues.each do |i|
                                i.notify action: :fixed,
                                         text: 'Marked as fixed as it did not ' <<
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
                logger.error e.to_s
                logger.error e.backtrace.join("\n")
            end
        end
    end

    def self.import( owner, file )
        report = Arachni::Report.load( file.path )

        # First, we need a profile.
        profile             = Profile.import_from_data( report.options )
        profile.owner       = owner
        profile.name        = "Placeholder #{Profile.count + 1}"
        profile.description = profile.name

        scan = new(
            url:         report.url,
            description: "Imported from '#{file.original_filename}'.",
            type:        :direct,
            profile:     profile,
            started_at:  report.start_datetime,
            finished_at: report.finish_datetime,
            owner:       owner,
            schedule:    Schedule.create(
                basetime: Schedule::BASETIME_OPTIONS.keys.first
            )
        )
        scan.create_report( report )
        scan.save

        profile.name        = "Created for imported scan ##{scan.id}"
        profile.description = "#{profile.name}."
        profile.save

        scan
    end

    def error_messages
        super.to_s
    end

    def create_report( r )
        begin
            self.report = Report.create( object: r, scan_id: id )
            save

            push_framework_issues( r.issues )
            update_from_framework_issues( r.issues )

            r
        rescue => e
            logger.error e.to_s
            logger.error e.backtrace.join("\n")
        end
    end

    private

    def handle_error( error )
        self.error_messages ||= ''
        self.error_messages  += "[#{error.class}] #{error}\n"

        if error.respond_to?( :backtrace ) && (error.backtrace || []).any?
            self.error_messages += "#{error.backtrace.join("\n")}\n"
        end

        self.error_messages += "#{'-' * 80}\n"
        self.error_messages += "#{caller.join("\n")}\n"
        self.error_messages += "#{'*' * 80}\n"

        save

        # If it's not a connection error then just logging it should be enough,
        # otherwise assume that the remote Instance has crashed and mark the
        # scan as errored.
        return if !error.rpc_connection_error?

        self.status = :error
        finish

        notify action: self.status
        delete_client
    end

    def delete_client
        client_synchronize do
            i = client_factory.delete( client_key )
            i.close if i
        end
    end

    def client_factory
        @@instances ||= {}
    end

    def client_synchronize( &block )
        (@@client_mutex ||= Mutex.new).synchronize(&block)
    end

    def client_key
        "#{instance_url}:#{instance_token}".hash
    end

    def push_framework_issues( a_issues )
        if revision?
            previous_rev_ids = previous_revisions_with_root.pluck( :id )
        end

        [a_issues].flatten.compact.each do |i|
            skip = revisions_issue_digests.include?( i.digest )

            if !issue_digests.include?( i.digest )
                issue_digests << i.digest
                save
            end

            if revision?
                previously_fixed_issue =
                    Issue.where( scan_id: previous_rev_ids,
                                 digest: i.digest.to_s, fixed: true ).first

                if previously_fixed_issue
                    previously_fixed_issue.notify action: :fixed,
                             text: 'Marked as unfixed as it re-appeared in ' <<
                                    "Revision ##{revision_index}."
                end

                # Mark issue as not fixed for all revisions since we came across it.
                Issue.where( scan_id: previous_rev_ids, digest: i.digest.to_s )
                    .update_all( { fixed: false } )
            end

            next if skip
            issues.create_from_framework_issue i
        end
    rescue => e
        logger.error e.to_s
        logger.error e.backtrace.join("\n")
    end

    def update_from_framework_issues( a_issues )
        [a_issues].flatten.compact.each do |i|
            issues.update_from_framework_issue( i, [:remarks, :requires_verification] )
        end
    end

    def save_report_and_shutdown( &block )
        # Grab the report and save the scan, we're all done now. :)
        instance.service.native_abort_and_report do |report|
            if report.rpc_exception?
                handle_error( report )
            else
                create_report( report )
            end

            instance.service.shutdown { delete_client }

            block.call if block_given?
        end
    end

    def finish
        self.active      = false
        self.finished_at = Time.now
        save

        return if !self.schedule.recurring?

        revision = new_revision

        basetime =  if revision.schedule.basetime == :started_at
                        self.started_at
                    else
                        self.finished_at
                    end

        start_at  = basetime + revision.schedule.interval
        start_at += revision.schedule.interval while start_at < Time.now

        revision.schedule.start_at = start_at
        revision.save
        revision.repeat
    end

    def validate_url
        if url.to_s.empty? ||
            (purl = Arachni::URI( url )).to_s.empty? || !purl.absolute?
            errors.add :url, 'not a valid absolute URL'
        end

        if !url.to_s.empty? && !Settings.scan_target_allowed?( url )
            if Settings.scan_target_whitelist_patterns.any? &&
                !Settings.scan_target_in_whitelist?( url )
                errors.add :url, 'not in the whitelist'
            end

            if Settings.scan_target_blacklist_patterns.any? &&
                Settings.scan_target_in_blacklist?( url )
                errors.add :url, 'is blacklisted'
            end
        end
    end

    def validate_type
        if [:grid, :remote].include?( type ) && !dispatcher && !load_balance?
            errors.add :type, "#{type.to_s.capitalize} scan is not available " +
                'as there are no suitable Dispatchers available'
        end
    end

    def validate_instance_count
        if instance_count < 1
            errors.add :instance_count, 'must be at least 1'
            return
        end

        return if !schedule.stop_suspend || instance_count == 1

        errors.add :instance_count, 'cannot be greater than 1 for a scheduled suspension'
    end

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

    def add_owner_to_subscribers
        self.user_ids |= [owner.id]
        true
    end

end
