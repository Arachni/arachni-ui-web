class Setting < ActiveRecord::Base
    serialize :scan_target_whitelist_patterns, Array
    serialize :scan_target_blacklist_patterns, Array
    serialize :scan_allowed_types, Array
    serialize :profile_allowed_checks,  Array
    serialize :profile_allowed_plugins, Array

    after_save :save_callback

    SCAN_TYPES = Scan::TYPES + [:multi_instance]

    def scan_target_whitelist_patterns=( string_or_hash )
        super self.class.string_list_to_array( string_or_hash )
    end

    def scan_target_blacklist_patterns=( string_or_hash )
        super self.class.string_list_to_array( string_or_hash )
    end

    def profile_allowed_plugins_with_info
        profile_allowed_plugins.
            inject( {} ) { |h, name| h[name] = ::FrameworkHelper.plugins[name]; h }
    end

    def profile_allowed_modules_with_info
        profile_allowed_modules.
            inject( {} ) { |h, name| h[name] = ::FrameworkHelper.checks[name]; h }
    end

    private

    def save_callback
        Time.zone = self.timezone
    end

    def self.string_list_to_array( string_or_array )
        case string_or_array
            when Array
                string_or_array
            else
                string_or_array.to_s.split( /[\n\r]/ ).reject( &:empty? )
        end
    end
end
