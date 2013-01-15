class Issue < ActiveRecord::Base
    belongs_to :scan

    validates_uniqueness_of :digest, scope: :scan_id

    # These can contain lots of junk characters which may blow up the SQL
    # statement (like null-bytes) so let the serializer deal with them.
    serialize :url,           String
    serialize :seed,          String
    serialize :response_body, String

    serialize :references,    Hash
    serialize :tags,          Array
    serialize :headers,       Hash
    serialize :audit_options, Hash

    FRAMEWORK_ISSUE_MAP = {
        name:            :name,
        description:     :description,
        url:             :url,
        var:             :vector_name,
        elem:            :vector_type,
        verification:    :requires_verification,
        cvssv2:          :cvssv2,
        cwe:             :cwe,
        method:          :http_method,
        tags:            :tags,
        headers:         :headers,
        regexp:          :signature,
        injected:        :seed,
        regexp_match:    :proof,
        response:        :response_body,
        opts:            :audit_options,
        references:      :references,
        remedy_code:     :remedy_code,
        remedy_guidance: :remedy_guidance,
        severity:        :severity,
        digest:          :digest
    }

    attr_accessible *FRAMEWORK_ISSUE_MAP.values

    def self.digests_for_scan( scan )
        select( [ :digest, :scan_id ] ).where( scan_id: scan.id )
    end

    def cwe_url
        return if cwe.to_s.empty?
        "http://cwe.mitre.org/data/definitions/#{cwe}.html"
    end

    def self.create_from_framework_issue( issue )
        create translate_framework_issue( issue )
    end

    def self.update_from_framework_issue( issue )
        where( digest: issue.digest ).first.
            update_attributes( translate_framework_issue( issue ) )
    end

    def self.translate_framework_issue( issue )
        h  = {}
        FRAMEWORK_ISSUE_MAP.each do |k, v|
            h[v] =  if !(iv = issue.send( k )).nil?
                        iv
                    else issue.variations.first &&
                        !(iv = issue.variations.first.send( k )).nil?
                        iv
                    end
        end

        h
    end

end
