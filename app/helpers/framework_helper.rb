=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module FrameworkHelper

    def framework( opts = Arachni::Options.instance, &block )
        fail 'This method requires a block.' if !block_given?
        f = Arachni::Framework.new( opts )
        begin
            block.call f
        ensure
            f.reset
        end
    end

    def checks
        components_for( :checks )
    end

    def plugins
        components_for( :plugins )
    end

    def default_plugins
        components_for( :plugins, :default )
    end

    def content_type_for_report( format )
        if !reporters[format.to_s] || !reporters[format.to_s][:content_type]
            return 'application/octet-stream'
        end

        reporters[format.to_s][:content_type]
    end

    def reporters
        components_for( :reporters ).reject { |name, _| name == 'txt' }
    end

    def reports_with_outfile
        h = {}
        reporters.
            reject { |_, info| !info[:options] || !info[:options].
                                map { |o| o.name  }.include?( :outfile ) }.
            map { |shortname, info| h[shortname] = [info[:name], info[:description]] }
        h
    end

    def components_for( type, list = :available )
        path = File.join( Rails.root, 'config', 'component_cache', "#{type}_#{list}.yml" )

        if !File.exists?( path )
            components = framework do |f|
                (manager = f.send( type )).send( list ).inject( {} ) do |h, name|
                    h[name] = manager[name].info.merge( path: manager.name_to_path( name ) )

                    if unsupported_component?( h[name][:options] )
                        h.delete( name )
                        next h
                    end

                    h[name][:author]    = [ h[name][:author] ].flatten
                    h[name][:authors]   = h[name][:author]

                    if manager[name] <= Arachni::Reporter::Base && manager[name].has_outfile?
                        h[name][:extension] = manager[name].outfile_option.default.split( '.', 2 ).last
                    end
                    h
                end
            end

            components = Hash[components.sort]

            File.open( path, 'w' ) do |f|
                f.write components.to_yaml
            end
        end

        YAML.load( IO.read( path ) )
    end

    def unsupported_component?( options )
        return false if !options
        options.each { |option| return true if option.type == :path && option.required? }
        false
    end

    extend self
end
