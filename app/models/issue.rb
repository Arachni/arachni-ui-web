class Issue < ActiveRecord::Base
    belongs_to :scan

    attr_accessible :cvssv2, :cwe, :description, :elem, :method, :name,
                    :references, :remedy_code, :remedy_guidance, :scan_id,
                    :severity, :url, :verification, :digest, :var
end
