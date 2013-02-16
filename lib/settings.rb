=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
=end

#
# Wraps the first {Setting} row for easier reference.
#
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
