=begin
    Copyright 2013-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class Report < ActiveRecord::Base
    belongs_to :scan

    serialize :object,  Arachni::Report
    serialize :sitemap, Hash

    def object=( report )
        self.sitemap = report.sitemap
        super( report )
    end

    def sitemap_urls
        sitemap.keys
    end

    def method_missing( name, *args, &block )
        if self[:object].respond_to?( name )
            self[:object].send( name, *args, &block )
        else
            super( name, *args, &block )
        end
    end

end
