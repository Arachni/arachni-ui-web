=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

#
# Wraps the first {Setting} row for easier reference.
#
class Settings

    SCAN_TYPES = Setting::SCAN_TYPES

    class << self
        [:scan_global_limit, :scan_per_user_limit, :profile_allowed_checks,
         :profile_allowed_plugins, :scan_target_whitelist_patterns,
         :scan_target_blacklist_patterns, :welcomed?, :timezone, :scan_auto_refresh?
        ].each do |sym|
            define_method sym do
                Setting.first.send( sym )
            end
        end

        def welcomed=( bool )
            s = Setting.first
            s.welcomed = bool
            s.save
            bool
        end

        def scan_allowed_types
            Setting.first.scan_allowed_types.map( &:to_sym )
        end

        def scan_target_in_whitelist?( url )
            scan_target_whitelist_patterns.each do |pattern|
                return true if url =~ Regexp.new( pattern )
            end

            false
        end

        def scan_target_in_blacklist?( url )
            scan_target_blacklist_patterns.each do |pattern|
                return true if url =~ Regexp.new( pattern )
            end

            false
        end

        def scan_target_allowed?( url )
            (scan_target_whitelist_patterns.empty? || scan_target_in_whitelist?( url )) &&
                (scan_target_blacklist_patterns.empty? || !scan_target_in_blacklist?( url ))
        end

        def user_scan_limit_exceeded?( user )
            user.scan_limit_exceeded?
        end

        def global_scan_limit_exceeded?
            Scan.limit_exceeded?
        end
    end

    Time.zone = self.timezone

end
