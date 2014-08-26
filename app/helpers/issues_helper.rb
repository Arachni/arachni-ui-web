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

module IssuesHelper

    def highlight_proof( text, proof, span_class )
        return h( text ) if !proof || !text.include?( proof )

        escaped_proof    = h( proof )
        escaped_response = h( text )

        escaped_response.gsub( escaped_proof,
                               "<span class=\"#{span_class}\">#{escaped_proof}</span>" )
    end

    def scan
        scan = Scan.find( params[:scan_id] )
        params[:overview] == 'true' ? scan.act_as_overview : scan
    end

    def issue_tab_description( type )
        case type
            when 'all'
                'Listing all logged issues.'

            when 'fixed'
                'These issues has been marked as fixed either manually or by '+
                    'not being found by future scan revisions.'

            when 'verified'
                'These issues have been verified as accurate by a human.'

            when 'pending-verification'
                'These issues have been marked as requiring human verification' +
                    ' either manually or by the scanner, due to being logged while ' +
                    'the server was behaving erratically.'

            when 'false-positives'
                'These issues have been marked as false-positives by a human.'

            when 'awaiting-review'
                'These issues haven\'t been reviewed yet.'
        end
    end

    def issue_filter( type )
        case type
            when 'fixed'
                scan.issues.fixed.light
            when 'verified'
                scan.issues.verified.light
            when 'pending-verification'
                scan.issues.pending_verification.light
            when 'false-positives'
                scan.issues.false_positives.light
            when 'awaiting-review'
                scan.issues - (scan.issues.verified +
                    scan.issues.pending_verification +
                    scan.issues.false_positives + scan.issues.fixed)
            else
                scan.issues.light
        end
    end

    def severities_from_issues( issues )
        h = {}
        issues.each do |issue|
            h[issue.severity] ||= []
            h[issue.severity] << issue
        end

        h.each { |severity, cissues| h[severity] = cissues.size }
        h
    end

    def group_issues_by_type( issues )
        h = {}
        issues.each do |issue|
            h[issue.name] ||= []
            h[issue.name] << issue
        end
        h
    end
end
