module ScansHelper

    def issue_severity_to_alert( severity )
        ap severity.to_s.downcase.to_sym

        case severity.to_s.downcase.to_sym
            when :high
                'important'
            when :medium
                'warning'
            when :low
                'default'
            when :informational
                'info'
        end
    end

    def response_times_to_alert( time )
        time = time.to_f

        if time >= 1
            [ 'alert-error',
              'The server takes too long to respond to the scan requests,' +
                  ' this will severely diminish performance.']
        elsif (0.5..1.0).include?( time )
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
