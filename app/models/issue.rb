=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class Issue < ActiveRecord::Base
    include Extensions::Notifier

    belongs_to :scan

    has_many :comments, as: :commentable, dependent: :destroy

    validate :validate_review_options
    validate :validate_verification_steps
    validate :validate_remediation_steps

    validates_uniqueness_of :digest, scope: :scan_id

    serialize :references,      Hash
    serialize :remarks,         Hash
    serialize :tags,            Array
    serialize :dom_transitions, Array
    serialize :headers,         Hash
    serialize :vector_inputs,   Hash

    FRAMEWORK_ISSUE_MAP = {
        name:            nil,
        description:     nil,
        references:      nil,
        remedy_code:     nil,
        remedy_guidance: nil,
        digest:          nil,
        cwe:             nil,
        tags:            nil,
        vector_type:     { vector:   { class: :type } },
        vector_html:     { vector:   :html },
        url:             { vector:   :action },
        severity:        { severity: { to_s: :capitalize } }
    }

    FRAMEWORK_ISSUE_VARIATION_MAP = {
        signature:             :signature,
        proof:                 :proof,
        requires_verification: :untrusted?,
        remarks:               :remarks,
        dom_transitions:       { page:     { dom: :transitions } },
        dom_body:              { page:     :body },
        http_method:           { vector:   :http_method },
        vector_inputs:         { vector:   :inputs },
        vector_name:           { vector:   :affected_input_name },
        seed:                  { vector:   :affected_input_value },
        response_body:         { response: :body },
        response:              { response: :to_s },
        request:               { request:  :to_s }
    }

    ORDERED_SEVERITIES = [
        Arachni::Issue::Severity::HIGH.to_s.capitalize,
        Arachni::Issue::Severity::MEDIUM.to_s.capitalize,
        Arachni::Issue::Severity::LOW.to_s.capitalize,
        Arachni::Issue::Severity::INFORMATIONAL.to_s.capitalize
    ]

    PROTECTED = [:remediation_steps, :verification_steps, :false_positive, :fixed]

    scope :fixed, -> { where fixed: true }
    scope :light, -> { select( column_names - %w(response_body references) ) }
    scope :false_positives, -> { where( 'false_positive = ?', true ) }
    scope :verified, -> do
        where( 'requires_verification = ? AND verified = ? AND ' +
                   'false_positive = ? AND fixed = ?', true, true, false, false )
    end
    scope :pending_verification, -> do
        where( 'requires_verification = ? AND verified = ? AND '+
                   ' false_positive = ? AND fixed = ?', true, false, false, false )
    end

    def self.order_by_severity
        ret = 'CASE'
        ORDERED_SEVERITIES.each_with_index do |p, i|
            ret << " WHEN severity = '#{p}' THEN #{i}"
        end
        ret << ' END'
    end
    scope :by_severity, -> { order order_by_severity }
    default_scope { by_severity }

    def timeline
        Notification.where( model_id: id, model_type: self.class.to_s,
                            user_id: scan.owner_id ).order( 'id desc' )
    end

    def id_name
        name#.parameterize
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

    def verified?
        super && !false_positive?
    end

    def pending_verification?
        requires_verification? && !verified? && !false_positive? && !fixed?
    end

    def pending_review?
        !verified && !false_positive && !requires_verification && !fixed?
    end

    def requires_verification_and_verified?
        requires_verification? && verified? && !false_positive?
    end

    def has_verification_steps?
        !verification_steps.to_s.empty?
    end

    def has_remediation_steps?
        !remediation_steps.to_s.empty?
    end

    def dom_body_contains_proof?
        proof && dom_body && dom_body.include?( proof )
    end

    def response_contains_proof?
        proof && response && response.include?( proof )
    end

    def to_s
        s = "#{name} in #{vector_type.capitalize}"
        s << " input '#{vector_name}'" if vector_name
        s
    end

    def cwe_url
        return if cwe.to_s.empty?
        "http://cwe.mitre.org/data/definitions/#{cwe}.html"
    end

    def subscribers
        scan.subscribers
    end

    def family
        [scan, self]
    end

    def self.describe_notification( action )
        case action
            when :destroy
                'was deleted'
            when :update, :reviewed
                'was reviewed'
            when :verified
                'was verified'
            when :fixed
                'has an updated fixed state'
            when :false_positive
                'has an updated false positive state'
            when :requires_verification
                'has an updated manual verification state'
            when :verification_steps
                'has updated verification steps'
            when :remediation_steps
                'has updated remediation steps'
            when :commented
                'has a new comment'
        end
    end

    def self.create_from_framework_issue( issue )
        create translate_framework_issue( issue )
    end

    def self.update_from_framework_issue( issue, update_only = [] )
        h = translate_framework_issue( issue )

        return if !(i = where( digest: issue.digest.to_s ).first)

        h.delete( :requires_verification ) if i.requires_verification?

        h.reject! { |k| !update_only.include? k } if update_only.any?

        i.update_attributes( h )
    end

    def self.translate_framework_issue( issue )
        h  = {}
        FRAMEWORK_ISSUE_MAP.each do |k, v|
            val = attribute_from_framework_issue( issue, v || k )
            h[k] = val.is_a?( String ) ? val.recode : val
        end

        FRAMEWORK_ISSUE_VARIATION_MAP.each do |k, v|
            val = attribute_from_framework_issue( issue, v || k )
            h[k] = val.is_a?( String ) ? val.recode : val
        end

        h.reject!{ |k, v| PROTECTED.include? k }

        h
    end

    private

    def self.attribute_from_framework_issue( issue, attribute )
        traverse_attributes( issue, attribute )
    end

    def self.traverse_attributes( object, path )
        return if object.nil?

        if path.is_a? Symbol
            return if !object.respond_to?( path )
            return object.send( path )
        end

        child_attribute = path.keys.first
        child_path      = path.values.first

        return if !object.respond_to?( child_attribute )

        traverse_attributes( object.send( child_attribute ), child_path )
    end

    def validate_review_options
        if false_positive && (requires_verification || verified)
            errors.add :false_positive, 'cannot include additional options'
        end
    end

    def validate_verification_steps
        return if ActionController::Base.helpers.strip_tags( verification_steps ) == verification_steps
        errors.add :verification_steps, 'cannot contain HTML, please use Markdown instead'
    end

    def validate_remediation_steps
        return if ActionController::Base.helpers.strip_tags( remediation_steps ) == remediation_steps
        errors.add :remediation_steps, 'cannot contain HTML, please use Markdown instead'
    end

end
