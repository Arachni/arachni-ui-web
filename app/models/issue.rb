class Issue < ActiveRecord::Base
    belongs_to :scan

    has_many :comments, as: :commentable, dependent: :destroy

    validates_uniqueness_of :digest, scope: :scan_id

    # These can contain lots of junk characters which may blow up the SQL
    # statement (like null-bytes) so let the serializer deal with them.
    serialize :url,           String
    serialize :seed,          String
    serialize :proof,         String
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
    attr_accessible :false_positive, :verified, :verification_steps

    before_save :set_verified_at

    ORDERED_SEVERITIES = [
        Arachni::Issue::Severity::HIGH,
        Arachni::Issue::Severity::MEDIUM,
        Arachni::Issue::Severity::LOW,
        Arachni::Issue::Severity::INFORMATIONAL
    ]

    def self.order_by_severity
        ret = "CASE"
        ORDERED_SEVERITIES.each_with_index do |p, i|
            ret << " WHEN severity = '#{p}' THEN #{i}"
        end
        ret << " END"
    end
    scope :by_severity, order: order_by_severity
    default_scope by_severity

    def self.light
        select( column_names - %w(response_body references) )
    end

    def url
        return nil if super.to_s.empty?
        super
    end

    def seed
        return nil if super.to_s.empty?
        super
    end

    def proof
        return nil if super.to_s.empty?
        super
    end

    def response_body
        return nil if super.to_s.empty?
        super
    end

    def signature
        return nil if super.to_s.empty?
        super
    end

    def self.verified
        where( 'requires_verification = ? AND verified = ?', true, true )
    end

    def self.pending_verification
        where( 'requires_verification = ? AND verified = ?', true, false )
    end

    def self.false_positives
        where( 'false_positive = ?', true )
    end

    def requires_verification_and_verified?
        requires_verification? && verified?
    end

    def has_verification_steps?
        !verification_steps.to_s.empty?
    end

    def base64_response_body
        Base64.encode64( response_body ).gsub( /\n/, '' )
    end

    def to_s
        s = "#{name} in #{vector_type.capitalize}"
        s << " input '#{vector_name}'" if vector_name
        s << ""
        s.html_safe
    end

    def cwe_url
        return if cwe.to_s.empty?
        "http://cwe.mitre.org/data/definitions/#{cwe}.html"
    end

    def response_body_contains_proof?
        proof && response_body && response_body.include?( proof )
    end

    def just_verified?
        verified_changed? && verified?
    end

    def subscribers
        scan.subscribers
    end

    def family
        [scan, self]
    end

    def self.digests_for_scan( scan )
        select( [ :digest, :scan_id ] ).where( scan_id: scan.id )
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

        if h[:headers]
            h[:headers][:request]  = h[:headers].delete( 'request' )
            h[:headers][:response] = h[:headers].delete( 'response' )
        end

        h
    end

    private

    def set_verified_at
        self.verified_at = just_verified? ? Time.now : nil
    end

end
