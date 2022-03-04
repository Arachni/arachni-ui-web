=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
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
