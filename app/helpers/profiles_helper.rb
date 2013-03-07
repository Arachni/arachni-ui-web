=begin
    Copyright 2013 Tasos Laskos <tasos.laskos@gmail.com>

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

module ProfilesHelper
    def messages_for( attribute )
        render partial: 'attribute_messages', locals: { attribute: attribute }
    end

    def render_options( plugin_name, plugin_info, configuration = {}, disabled = false )
        tpl = "#{Rails.root}/app/views/profiles/plugin_options/#{plugin_name}/#{params[:action]}.html.erb"
        opts = {
            plugin_name:   plugin_name,
            info:          plugin_info,
            configuration: configuration,
            disabled:      disabled
        }

        if File.exist? tpl
            render file: tpl, locals: opts
        else
            render partial: 'profiles/plugin_options/generic', locals: opts
        end
    end

    def profile_filter( filter )
        filter ||= 'yours'

        case filter
            when 'yours'
                current_user.profiles.where( owner_id: current_user.id )
            when 'shared'
                current_user.profiles.where( "owner_id != ?", current_user.id )
            when 'global'
                Profile.global

            when 'others'
                raise 'Unauthorised!' if !current_user.admin?

                ids = current_user.profiles.select( :id ).
                    where( "owner_id != ?", current_user.id ) +
                    current_user.profiles.select( :id ).
                        where( "owner_id = ?", current_user.id )

                Profile.where( id: Profile.select( :id ) - ids )
        end
    end

    def prepare_description( str )
        placeholder =  '--' + rand( 1000 ).to_s + '--'
        cstr = str.gsub( /^\s*$/xm, placeholder )
        cstr.gsub!( /^\s*/xm, '' )
        cstr.gsub!( placeholder, "\n" )
        cstr.chomp
    end

end
