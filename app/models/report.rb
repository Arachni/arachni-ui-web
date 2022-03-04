=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class Report < ActiveRecord::Base
    class ArachniReportWrapper
        def self.load( string )
            return if string.nil?

            Arachni::Report.from_rpc_data MessagePack.load( string )
        end

        def self.dump( report )
            MessagePack.dump( report.to_rpc_data )
        end
    end

    belongs_to :scan

    serialize :object,  ArachniReportWrapper
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
