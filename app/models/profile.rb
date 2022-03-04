=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class Profile < ActiveRecord::Base
    include Extensions::Notifier

    has_and_belongs_to_many :users
    has_many :scans
    belongs_to :owner, class_name: 'User', foreign_key: :owner_id

   DESCRIPTIONS_FILE = "#{Rails.root}/config/profile/attributes.yml"

    validates_presence_of   :name
    validates_uniqueness_of :name, scope: :owner_id, case_sensitive: false

    validates_presence_of   :description

    validate :validate_description
    validate :validate_plugins
    validate :validate_plugin_options
    validate :validate_scope_redundant_path_patterns
    validate :validate_http_request_concurrency
    validate :validate_http_cookies
    validate :validate_http_request_headers
    validate :validate_session_check
    validate :validate_scope_url_rewrites

    # #checks= will ignore any any checks which have not specifically been
    # authorized so this is not strictly required.
    validate :validate_checks

    serialize :http_cookies,                   Hash
    serialize :http_request_headers,           Hash
    serialize :scope_exclude_path_patterns,    Array
    serialize :scope_exclude_file_extensions,  Array
    serialize :scope_exclude_content_patterns, Array
    serialize :scope_include_path_patterns,    Array
    serialize :scope_extend_paths,             Array
    serialize :scope_restrict_paths,           Array
    serialize :scope_redundant_path_patterns,  Hash
    serialize :scope_url_rewrites,             Hash
    serialize :audit_exclude_vector_patterns,  Array
    serialize :audit_include_vector_patterns,  Array
    serialize :audit_link_templates,           Array
    serialize :checks,                         Array
    serialize :platforms,                      Array
    serialize :plugins,                        Hash
    serialize :input_values,                   Hash

    before_save :sanitize_platforms
    before_save :add_owner_to_subscribers

    RPC_OPTS = [
        :audit_cookies,
        :audit_nested_cookies,
        :audit_cookies_extensively,
        :audit_exclude_vector_patterns,
        :audit_forms,
        :audit_ui_forms,
        :audit_ui_inputs,
        :audit_headers,
        :audit_jsons,
        :audit_xmls,
        :audit_include_vector_patterns,
        :audit_link_templates,
        :audit_links,
        :audit_with_both_http_methods,
        :authorized_by,
        :browser_cluster_ignore_images,
        :browser_cluster_job_timeout,
        :browser_cluster_pool_size,
        :browser_cluster_screen_height,
        :browser_cluster_screen_width,
        :browser_cluster_worker_time_to_live,
        :checks,
        :http_authentication_password,
        :http_authentication_username,
        :http_authentication_type,
        :http_cookies,
        :http_proxy_host,
        :http_proxy_password,
        :http_proxy_port,
        :http_proxy_type,
        :http_proxy_username,
        :http_request_concurrency,
        :http_request_headers,
        :http_request_queue_size,
        :http_request_redirect_limit,
        :http_request_timeout,
        :http_response_max_size,
        :http_user_agent,
        :input_values,
        :session_check_pattern,
        :session_check_url,
        :no_fingerprinting,
        :platforms,
        :plugins,
        :scope_auto_redundant_paths,
        :scope_directory_depth_limit,
        :scope_dom_depth_limit,
        :scope_exclude_binaries,
        :scope_exclude_content_patterns,
        :scope_exclude_path_patterns,
        :scope_extend_paths,
        :scope_https_only,
        :scope_include_path_patterns,
        :scope_include_subdomains,
        :scope_page_limit,
        :scope_redundant_path_patterns,
        :scope_restrict_paths,
        :scope_url_rewrites,
        :scope_exclude_file_extensions,
        :spawns
    ]

    scope :global, -> { where global: true }

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

    def self.default
        self.where( default: true ).first
    end

    def self.unmake_default
        update_all default: false
    end

    def self.recent( limit = 5 )
        order( 'id desc' ).limit( limit )
    end

    def self.light
        select( [:id, :name] )
    end

    def subscribers
        users | [owner]
    end

    def family
        [self]
    end

    def to_s
        name
    end

    def name
        n = super
        return if !n

        n.force_encoding('utf-8')
    end

    def has_scheduled_scans?
        scans.scheduled.any?
    end

    def make_default
        self.class.unmake_default
        self.default = true
        self.save
    end

    def default?
        !!self.default
    end

    def to_rpc_options
        opts = {}
        attributes.each do |k, v|
            next if !RPC_OPTS.include?( k.to_sym ) || v.nil? ||
                (v.respond_to?( :empty? ) ? v.empty? : false)

            if (group_name = find_group_option( k ))
                group_name = group_name.to_s
                opts[group_name] ||= {}
                opts[group_name][k[group_name.size+1..-1]] = v
            else
                opts[k] = v
            end
        end

        opts = Arachni::Options.hash_to_rpc_data( opts )
        opts['input']['without_defaults'] = true
        opts['input'].delete 'default_values'

        opts
    end

    def find_group_option( name )
        Arachni::Options.group_classes.keys.find { |n| name.start_with? "#{n}_" }
    end

    def export( serializer = YAML )
        profile_hash = to_rpc_options
        profile_hash[:name] = name
        profile_hash[:description] = description

        profile_hash = profile_hash.stringify_keys
        if serializer == JSON
            JSON::pretty_generate profile_hash
        else
            serializer.dump profile_hash
        end
    end

    def checks
        # Only allow authorized checks.
        super & Settings.profile_allowed_checks
    end

    def plugins
        # Only allow authorized plugins.
        super.select { |k, _| Settings.profile_allowed_plugins.include? k }
    end

    def html_description
        ApplicationHelper.m description
    end

    def html_description_excerpt( *args )
        ApplicationHelper.truncate_html *[html_description, args].flatten
    end

    def scope_exclude_file_extensions=( string_or_array )
        case string_or_array
            when Array
                super string_or_array
            else
                super string_or_array.to_s.split( /\s+/ )
        end
    end

    %w(scope_exclude_path_patterns scope_exclude_content_patterns
        scope_include_path_patterns scope_restrict_paths scope_extend_paths
        audit_exclude_vector_patterns audit_include_vector_patterns audit_link_templates).each do |m|
        define_method "#{m}=" do |string_or_array|
            super self.class.string_list_to_array( string_or_array )
        end

        validate "validate_#{m}".to_sym

        define_method "validate_#{m}" do
            send( m ).each do |pattern|
                check_pattern( pattern, m )
            end
        end
    end

    %w(scope_redundant_path_patterns scope_url_rewrites).each do |m|
        define_method "#{m}=" do |string_or_hash|
            super self.class.string_list_to_hash( string_or_hash, ':' )
        end
    end

    %w(http_cookies http_request_headers input_values).each do |m|
        define_method "#{m}=" do |string_or_hash|
            super self.class.string_list_to_hash( string_or_hash, '=' )
        end
    end

    def checks=( m )
        # Only allow authorized checks.

        if m == :all || m == :default
            return super( ::FrameworkHelper.checks.keys.map( &:to_s ) & Settings.profile_allowed_checks.to_a )
        end

        super m & Settings.profile_allowed_checks.to_a
    end

    def plugins=( p )
        # Only allow authorized plugins.

        if p == :default
            c = ::FrameworkHelper.default_plugins.keys.inject( {} ) { |h, name| h[name] = {}; h }
            return super c
        end

        super p.select { |k, _| Settings.profile_allowed_plugins.include? k }
    end

    def checks_with_info
        checks.inject( {} ) { |h, name| h[name] = ::FrameworkHelper.checks[name]; h }
    end

    def has_checks?
        self.checks.any?
    end

    def has_plugins?
        self.plugins.any?
    end

    def plugins_with_info
        plugins.keys.inject( {} ) { |h, name| h[name] = ::FrameworkHelper.plugins[name]; h }
    end

    def self.string_for( attribute, type = nil )
        @descriptions ||= YAML.load( IO.read( DESCRIPTIONS_FILE ) )

        case description = @descriptions[attribute.to_s]
            when String
                return if type != :description
                description
            when Hash
                description[type.to_s]
        end
    end

    def self.description_for( attribute )
        string_for( attribute, :description )
    end
    def description_for( attribute )
        self.class.description_for( attribute )
    end

    def self.notice_for( attribute )
        string_for( attribute, :notice )
    end
    def notice_for( attribute )
        self.class.notice_for( attribute )
    end

    def self.warning_for( attribute )
        string_for( attribute, :warning )
    end
    def warning_for( attribute )
        self.class.warning_for( attribute )
    end

    def self.string_list_to_array( string_or_array )
        case string_or_array
            when Array
                string_or_array
            else
                string_or_array.to_s.split( /[\n\r]/ ).reject( &:empty? )
        end
    end

    def self.string_list_to_hash( string_or_hash, hash_delimiter )
        case string_or_hash
            when Hash
                string_or_hash
            else
                Hash[string_or_hash.to_s.split( /[\n\r]/ ).reject( &:empty? ).
                               map{ |rule| rule.split( hash_delimiter, 2 ) }]
        end
    end

    def self.import( file )
        serialized = file.read

        data = begin
                JSON.load serialized
            rescue
                YAML.safe_load serialized rescue nil
            end

        return if !data.is_a?( Hash )

        # Old Profile, not supported.
        return if data.include?( 'modules' ) || data.include?( 'mods' )

        data['name']        ||= file.original_filename
        data['description'] ||= "Imported from '#{file.original_filename}'."

        import_from_data( data )
    end

    def self.import_from_data( data )
        options = {}
        data.each do |name, value|
            if Arachni::Options.group_classes.include?( name.to_sym )
                value.each do |k, v|
                    key = "#{name}_#{k}"
                    next if !attribute_names.include?( key.to_s )

                    options[key] = v
                end
            else
                next if !attribute_names.include?( name.to_s )
                options[name] = value
            end
        end

        new options
    end

    def validate_description
        return if ActionController::Base.helpers.strip_tags( description ) == description
        errors.add :description, 'cannot contain HTML, please use Markdown instead'
    end

    def validate_scope_redundant_path_patterns
        scope_redundant_path_patterns.each do |pattern, counter|
            next if counter.to_i > 0
            errors.add :scope_redundant_path_patterns,
                       "rule '#{pattern}' needs an integer counter greater than 0"
        end
    end

    def validate_scope_url_rewrites
        scope_url_rewrites.each do |pattern, substitution|
            pattern      = pattern.to_s.strip
            substitution = substitution.to_s.strip

            if pattern.empty?
                errors.add :scope_url_rewrites, 'pattern cannot be empty'
                next
            end

            if substitution.empty?
                errors.add :scope_url_rewrites,
                           "substitution for pattern #{pattern} cannot be empty"
                next
            end

            next if !check_pattern( pattern, :scope_url_rewrites )

            if !(pattern =~ /\(.*\)/)
                ap 111111
                errors.add :scope_url_rewrites,
                           "pattern #{pattern} includes no captures"
            end

            if !(substitution =~ /\\\d/)
                errors.add :scope_url_rewrites,
                           "substitution #{substitution} includes no substitutions"
            end
        end
    end

    def check_pattern( pattern, attribute )
        Regexp.new( pattern.to_s )
        true
    rescue RegexpError => e
        errors.add attribute, "invalid pattern #{pattern.inspect} (#{e})"
        false
    end

    def validate_http_cookies
        http_cookies.each do |name, value|
            errors.add :http_cookies, "name cannot be blank ('#{name}=#{value}')" if name.empty?
        end
    end

    def validate_http_request_concurrency
        return if http_request_concurrency.to_i > 0
        errors.add :http_request_concurrency, 'must be higher than 0'
    end

    def validate_http_request_headers
        http_request_headers.each do |name, value|
            errors.add :http_request_headers, "name cannot be blank ('#{name}=#{value}')" if name.empty?
        end
    end

    def validate_session_check
        return if session_check_url.to_s.empty? && session_check_pattern.to_s.empty?
        if (url = Arachni::URI( session_check_url )).to_s.empty? || !url.absolute?
            errors.add :session_check_url, 'not a valid absolute URL'
        end

        errors.add :session_check_pattern, 'cannot be blank' if session_check_pattern.to_s.empty?

        begin
            Regexp.new( session_check_pattern )
        rescue RegexpError => e
            errors.add :session_check_pattern, "not a valid regular expression (#{e})"
        end
    end

    def validate_checks
        available = ::FrameworkHelper.checks.keys.map( &:to_s )
        checks.each do |check|
            next if available.include? check.to_s
            errors.add :checks, "'#{check}' does not exist"
        end
    end

    def validate_plugins
        available = ::FrameworkHelper.plugins.keys.map( &:to_s )
        plugins.keys.each do |plugin|
            next if available.include? plugin.to_s
            errors.add :plugins, "'#{plugin}' does not exist"
        end
    end

    def validate_plugin_options
        available = ::FrameworkHelper.plugins.keys.map( &:to_s )
        ::FrameworkHelper.framework do |f|
            plugins.each do |plugin, options|
                next if !available.include? plugin.to_s

                begin
                    f.plugins.prepare_options( plugin, f.plugins[plugin],
                                               (options || {}).reject { |k, v| v.empty? }
                    )
                rescue Arachni::Component::Options::Error::Invalid => e
                    errors.add :plugins, e.to_s
                end
            end
        end
    end

    private

    def sanitize_platforms
        self.platforms.reject!{ |p| p.to_s.empty? }
        true
    end

    def add_owner_to_subscribers
        self.user_ids |= [owner.id]
        true
    end
end
