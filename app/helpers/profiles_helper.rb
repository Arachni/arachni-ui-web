=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

module ProfilesHelper
    include ApplicationHelper

    def valid_platforms( type = nil )
        (type.nil? ? platform_manager.valid : platform_manager.send( type ).valid).map( &:to_s )
    end

    def platform_type_fullname( type )
        Arachni::Platform::Manager::TYPES[type]
    end

    def platform_fullname( platform )
        platform_manager.fullname platform
    end

    def platform_manager
        @platform_manager ||= Arachni::Platform::Manager.new
    end

    def modules
        allowed = Settings.profile_allowed_modules.reject { |m| m.to_s.empty?}
        super.select { |name, _| allowed.include? name }
    end

    def plugins
        allowed = Settings.profile_allowed_plugins.reject { |m| m.to_s.empty?}
        super.select { |name, _| allowed.include? name }
    end

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
