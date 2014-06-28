=begin
    Copyright 2013-2014 Tasos Laskos <tasos.laskos@gmail.com>

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
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
        reports[format.to_s][:content_type] || 'application/octet-stream'
    end

    def reports
        components_for( :reports ).
            reject { |name, _| ['metareport', 'txt'].include? name }
    end

    def reports_with_outfile
        h = {}
        reports.
            reject { |_, info| !info[:options] || !info[:options].
                map { |o| o.name  }.include?( 'outfile' ) }.
            map do |name, info|
                h[info[:extension]] = [info[:name], info[:description]]
            end
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

                    if manager[name] <= Arachni::Report::Base && manager[name].has_outfile?
                        h[name][:extension] = manager[name].outfile_option.default.split( '.' ).last
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
        options.each { |option| return true if option.type == 'path' && option.required? }
        false
    end

    extend self
end
