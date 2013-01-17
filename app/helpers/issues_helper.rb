module IssuesHelper

    def highlight_issue_response_body( issue, span_class )
        return h( issue.response_body ) if !issue.response_body_contains_proof?

        escaped_proof         = h( issue.proof )
        escaped_response_body = h( issue.response_body )

        escaped_response_body.gsub( escaped_proof,
                                  "<span class=\"#{span_class}\">#{escaped_proof}</span>" )
    end

end
