=begin
    Copyright 2013-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

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

class ScanOverview

    def initialize( scan )
        @scan = scan.root_revision
    end

    def fixed_issues
        revisions_with_root.light.map( &:fixed_issues ).
            flatten.compact.
            sort_by { |i| Issue::ORDERED_SEVERITIES.index i.severity }
    end

    def issues
        @scan.revisions_issues
    end

    def sitemap
        @scan.revisions_sitemap
    end

    def issue_count
        @scan.revisions_issue_count
    end

    def issue_digests
        @scan.revisions_issue_digests
    end

    def revisions
        @scan.revisions
    end

    def revisions_with_root
        @scan.revisions_with_root
    end

end
