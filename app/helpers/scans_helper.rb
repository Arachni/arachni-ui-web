=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module ScansHelper

    def prepare_tables_data
        params[:filter_finished]  ||= 'yours'
        params[:filter_active]    ||= 'yours'
        params[:filter_suspended] ||= 'yours'

        @counts = {
            active: {},
            finished: {},
            suspended: {}
        }
        %w(yours shared others).each do |type|
            begin
                @counts[:active][type] = scan_filter( type ).active.count
                @counts[:active]['total'] ||= 0
                @counts[:active]['total']  += @counts[:active][type]

                @counts[:finished][type] = scan_filter( type ).finished.count
                @counts[:finished]['total'] ||= 0
                @counts[:finished]['total']  += @counts[:finished][type]

                @counts[:suspended][type] = scan_filter( type ).suspended.count
                @counts[:suspended]['total'] ||= 0
                @counts[:suspended]['total']  += @counts[:suspended][type]
            rescue
            end
        end

        @active_scans = scan_filter( params[:filter_active] ).active.
                            page( params[:active_page] ).
                            per( HardSettings.active_scan_pagination_entries ).
                            order( 'id DESC' )

        @finished_scans = scan_filter( params[:filter_finished] ).roots.finished.
                            page( params[:finished_page] ).
                            per( HardSettings.finished_scan_pagination_entries ).
                            order( 'id DESC' )

        @suspended_scans = scan_filter( params[:filter_suspended] ).roots.suspended.
                            page( params[:suspended_page] ).
                            per( HardSettings.finished_scan_pagination_entries ).
                            order( 'id DESC' )
    end

    def prepare_schedule_data
        params[:filter] ||= 'yours'

        @counts = {}
        %w(yours shared others).each do |type|
            begin
                @counts[type] = scan_filter( type ).scheduled.count

                @counts['total'] ||= 0
                @counts['total']  += @counts[type]
            rescue => e
                ap e
                ap e.backtrace
            end
        end

        @scans = scan_filter( params[:filter] ).scheduled.
            page( params[:active_page] ).
            per( HardSettings.scheduled_scan_pagination_entries ).
            order( 'id DESC' )
    end

    def scan_filter( filter )
        filter ||= 'yours'

        group_scans =   if (group_id = params[:group_id].to_i) > 0
                            if current_user.admin?
                                if (@group = ScanGroup.find_by_id( params[:group_id] ))
                                    @group.scans
                                else
                                    current_user.scans
                                end
                            else
                                @group = current_user.scan_groups.find_by_id( params[:group_id] )

                                if @group
                                    @group.scans
                                else
                                    current_user.scans
                                end
                            end
                        else
                            current_user.scans
                        end

        case filter
            when 'yours'
                group_scans.where( owner_id: current_user.id )

            when 'shared'
                s = group_scans.where( 'owner_id != ?', current_user.id )

                if current_user.admin?
                    s.where( 'id in (?)', current_user.scans.pluck( :id ) )
                else
                    s
                end

            when 'others'
                raise 'Unauthorised!' if !current_user.admin?

                ids = group_scans.where( 'owner_id != ?', current_user.id ).
                        where( 'id in (?)', current_user.scans.pluck( :id ) ) +
                    group_scans.select( :id ).
                        where( owner_id: current_user.id )

                rest_ids = if group_id
                               group_scans
                           else
                               Scan
                           end.select( :id )

                Scan.where( id: rest_ids - ids )
        end
    end

    def issues_to_graph_data( issues )
        graph_data = {
            severities:       {
                Arachni::Severity::HIGH.to_sym          => 0,
                Arachni::Severity::MEDIUM.to_sym        => 0,
                Arachni::Severity::LOW.to_sym           => 0,
                Arachni::Severity::INFORMATIONAL.to_sym => 0
            },
            issues:           {},
            elements:         {
                Arachni::Element::Form.type              => 0,
                Arachni::Element::Form::DOM.type         => 0,
                Arachni::Element::Link.type              => 0,
                Arachni::Element::Link::DOM.type         => 0,
                Arachni::Element::Cookie.type            => 0,
                Arachni::Element::Cookie::DOM.type       => 0,
                Arachni::Element::Header.type            => 0,
                Arachni::Element::LinkTemplate.type      => 0,
                Arachni::Element::LinkTemplate::DOM.type => 0,
                Arachni::Element::GenericDOM.type        => 0,
                Arachni::Element::XML.type               => 0,
                Arachni::Element::JSON.type              => 0,
                Arachni::Element::UIForm.type            => 0,
                Arachni::Element::UIForm::DOM.type       => 0,
                Arachni::Element::UIInput.type           => 0,
                Arachni::Element::UIInput::DOM.type      => 0,
                Arachni::Element::Body.type              => 0,
                Arachni::Element::Path.type              => 0,
                Arachni::Element::Server.type            => 0
            }
        }

        total_severities = 0
        total_elements   = 0

        issues.each.with_index do |issue, i|
            graph_data[:severities][issue.severity.downcase.to_sym] += 1
            total_severities += 1

            graph_data[:issues][issue.name] ||= 0
            graph_data[:issues][issue.name] += 1

            graph_data[:elements][issue.vector_type.to_sym] += 1
            total_elements += 1
        end

        graph_data
    end

    def response_times_to_alert( time )
        time = time.to_f

        if time >= 0.7
            [ 'alert-error',
              'The server takes too long to respond to the scan requests,' +
                  ' this will severely diminish performance.']
        elsif (0.35..0.7).include?( time )
            [ 'alert-warning',
              'Server response times could be better but nothing to worry about yet.' ]
        else
            [ 'alert-success',
              'Server response times are excellent.' ]
        end
    end

    def concurrent_requests_to_alert( request_count, max )
        max = max.to_i
        request_count = request_count.to_i

        if request_count >= max
            [ 'alert-success',
              'HTTP request concurrency is operating at the allowed maximum.']
        elsif ((max/2)..max).include?( request_count )
            [ 'alert-warning',
              "HTTP request concurrency had to be throttled down (from the " +
                  "maximum of #{max}) due to high server response times, " +
                  'nothing to worry about yet though.' ]
        else
            [ 'alert-error',
              'HTTP request concurrency has been drastically throttled down ' +
                  "(from the maximum of #{max}) due to very high server" +
                  " response times, this will severely decrease performance."]
        end
    end
end
