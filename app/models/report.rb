class Report < ActiveRecord::Base
    belongs_to :scan

    attr_accessible :object, :scan_id

    serialize :object,  Arachni::AuditStore
    serialize :sitemap, Array

    def object=( report )
        self.sitemap = report.sitemap
        super( report )
    end

    def method_missing( name, *args, &block )
        if object.respond_to?( name )
            object.send( name, *args, &block )
        else
            super( name, *args, &block )
        end
    end

    def responds_to( name )
        object.respond_to?( name ) || super( name )
    end

end
