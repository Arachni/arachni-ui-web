class Setting < ActiveRecord::Base
    serialize :target_whitelist_patterns, Array
    serialize :target_blacklist_patterns, Array

    def target_whitelist_patterns=( string_or_hash )
        super self.class.string_list_to_array( string_or_hash )
    end

    def target_blacklist_patterns=( string_or_hash )
        super self.class.string_list_to_array( string_or_hash )
    end

    private

    def self.string_list_to_array( string_or_array )
        case string_or_array
            when Array
                string_or_array
            else
                string_or_array.to_s.split( /[\n\r]/ ).reject( &:empty? )
        end
    end
end

class Settings

    class << self
        [:global_scan_limit, :per_user_scan_limit,
         :target_whitelist_patterns, :target_blacklist_patterns].each do |sym|
            define_method sym do
                Setting.first.send( sym )
            end
        end

        def target_in_whitelist?( url )
            target_whitelist_patterns.each do |pattern|
                return true if url =~ Regexp.new( pattern )
            end

            false
        end

        def target_in_blacklist?( url )
            target_blacklist_patterns.each do |pattern|
                return true if url =~ Regexp.new( pattern )
            end

            false
        end

        def target_allowed?( url )
            (target_whitelist_patterns.empty? || target_in_whitelist?( url )) &&
                (target_blacklist_patterns.empty? || !target_in_blacklist?( url ))
        end

        def user_scan_limit_exceeded?( user )
            user.scan_limit_exceeded?
        end

        def global_scan_limit_exceeded?
            Scan.limit_exceeded?
        end
    end

end
