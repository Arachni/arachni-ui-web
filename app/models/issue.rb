class Issue < ActiveRecord::Base
    belongs_to :scan

    validates_uniqueness_of :digest, scope: :scan_id

    attr_accessible :cvssv2, :cwe, :description, :elem, :method, :name,
                    :references, :remedy_code, :remedy_guidance, :scan_id,
                    :severity, :url, :verification, :digest, :var

    serialize :references, Hash

    def self.digests_for_scan( scan )
        select( [ :digest, :scan_id ] ).where( scan_id: scan.id )
    end

    def cwe_url
        return if cwe.to_s.empty?
        "http://cwe.mitre.org/data/definitions/#{cwe}.html"
    end

end
