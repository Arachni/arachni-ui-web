=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class ProfilesController < ApplicationController
    include ProfilesHelper
    include NotificationsHelper

    before_action :authenticate_user!
    before_action :prepare_plugin_params
    before_action :new_profile, only: [ :create ]

    load_and_authorize_resource

    # GET /profiles
    # GET /profiles.json
    def index
        params.permit!
        prepare_table_data

        respond_to do |format|
            format.html # index.html.erb
            format.js { render '_table.js' }
            format.json { render json: @profiles }
        end
    end

    # GET /profiles/1
    # GET /profiles/1.json
    # GET /profiles/1.yaml
    def show
        @profile = Profile.find( params.require( :id ) )

        set_download_header = proc do |extension|
            name = @profile.name
            [ "\n", "\r", '"' ].each { |k| name.gsub!( k, '' ) }

            headers['Content-Disposition'] =
                "attachment; filename=\"Arachni WebUI Profile - #{name}.#{extension}\""
        end

        respond_to do |format|
            format.html # show.html.erb
            format.js { render @profile }
            format.json do
                set_download_header.call 'json'
                render text: @profile.export( JSON )
            end
            format.yaml do
                set_download_header.call 'yaml'
                render text: @profile.export( YAML )
            end
            format.afp do
                set_download_header.call 'afp'
                render text: @profile.to_rpc_options.to_yaml
            end
        end
    end

    # GET /profiles/new
    # GET /profiles/new.json
    def new
        @profile = Profile.new

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @profile }
        end
    end

    # GET /profiles/1/copy
    def copy
        @profile = Profile.find( params.require( :id ) ).dup
        @profile.owner_id = nil
        @profile.global   = false

        respond_to do |format|
            format.html { render 'new' }
        end
    end

    # GET /profiles/1/edit
    def edit
        @profile = Profile.find( params.require( :id ) )
    end

    # PUT /profiles/1/make_default
    def make_default
        profile = Profile.find( params.require( :id ) )

        fail 'Cannot make a non-global profile the default one.' if !profile.global?

        profile.make_default
        params.delete( :id )

        notify profile

        prepare_table_data

        render partial: 'table', formats: :js
    end

    # POST /profiles
    # POST /profiles.json
    def create
        @profile.owner = current_user

        respond_to do |format|
            if @profile.save
                notify @profile

                format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
                format.json { render json: @profile, status: :created, location: @profile }
            else
                format.html { render action: 'new' }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
        end
    end

    # POST /profiles/import
    def import
        if !params[:profile] || !params[:profile][:file].is_a?( ActionDispatch::Http::UploadedFile )
            redirect_to profiles_url, alert: 'No file selected for import.'
            return
        end

        @profile = Profile.import( params[:profile][:file] )

        if !@profile
            redirect_to profiles_url,
                        alert: 'Could not understand the Profile format, please' <<
                            ' ensure that you are using a v0.5 profile.'
            return
        end

        respond_to do |format|
            format.html { render 'edit' }
        end
    end

    # PUT /profiles/1
    # PUT /profiles/1.json
    def update
        @profile = Profile.find( params.require( :id ) )

        respond_to do |format|
            if @profile.update_attributes( strong_params )
                notify @profile

                format.html { redirect_to @profile, notice: 'Profile was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
        end
    end

    def share
        @profile = Profile.find( params.require( :id ) )

        respond_to do |format|
            if @profile.update_attributes( params.require( :profile ).permit( user_ids: [] ) )
                notify @profile

                format.html { redirect_back fallback_location: profiles_path, notice: 'Profile was successfully shared.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /profiles/1
    # DELETE /profiles/1.json
    def destroy
        @profile = Profile.find( params.require( :id ) )
        fail 'Cannot delete default Profile.' if @profile.default?
        fail 'Cannot delete Profiles assigned to scheduled Scans.' if @profile.has_scheduled_scans?

        notify @profile
        @profile.destroy

        respond_to do |format|
            format.html { redirect_to profiles_url }
            format.json { head :no_content }
        end
    end

    private

    def new_profile
        @profile = Profile.new( strong_params )
    end

    def strong_params
        plugins_with_options = []
        plugins_with_info = ::FrameworkHelper.plugins
        plugins_with_info.each do |name, info|
            plugins_with_options << (info[:options] ?
                { name => info[:options].map( &:name ) } : name)
        end

        allowed = [
            :name, :audit_cookies, :audit_nested_cookies, :audit_cookies_extensively, :audit_forms,
            :audit_headers, :audit_links, :audit_jsons, :audit_xmls,
            :audit_ui_forms,:audit_ui_inputs, :authorized_by, :scope_auto_redundant_paths,
            :audit_exclude_vector_patterns, :audit_include_vector_patterns,
            :http_cookies, :http_request_headers, :scope_directory_depth_limit,
            :scope_exclude_path_patterns, :scope_exclude_path_patterns_binaries,
            :scope_exclude_path_patterns_cookies, :scope_extend_paths,
            :scope_include_subdomains, :audit_with_both_http_methods,
            :http_request_concurrency, :scope_include_path_patterns,
            :scope_page_limit, :session_check_pattern, :session_check_url,
            :spawns, :min_pages_per_instance, { checks: [] }, { selected_plugins: []},
            { plugins: plugins_with_options }, :http_proxy_host,
            :http_proxy_password, :http_proxy_port, :http_proxy_type,
            :http_proxy_username, :http_request_redirect_limit,
            :scope_redundant_path_patterns, :scope_restrict_paths,
            :http_user_agent, :http_request_timeout, :description,
            :scope_https_only, :scope_exclude_content_patterns, { user_ids: [] },
            :no_fingerprinting, { platforms: [] }, :http_authentication_username,
            :http_authentication_password, :input_values, :browser_cluster_pool_size,
            :browser_cluster_job_timeout, :browser_cluster_worker_time_to_live,
            :browser_cluster_ignore_images, :browser_cluster_screen_width,
            :browser_cluster_screen_height, :scope_dom_depth_limit,
            :audit_link_templates, :http_request_queue_size, :http_response_max_size,
            :scope_url_rewrites, :scope_exclude_binaries, :scope_exclude_file_extensions,
            :http_authentication_type
        ]

        allowed << :global if current_user.admin?

        # Make sure no ActionController::Parameters sneak in.
        params_to_hash params.require( :profile ).permit( *allowed )
    end

    def prepare_plugin_params
        return if !params[:profile]

        if params[:profile][:selected_plugins]
            selected_plugins = {}
            (params[:profile][:selected_plugins] || []).each do |plugin|
                selected_plugins[plugin] = params[:profile][:plugins][plugin]
            end

            params[:profile][:plugins] = selected_plugins
            params[:profile].delete( :selected_plugins )
        else
            params[:profile][:plugins] = {}
        end
    end

    def prepare_table_data
        @profiles = profile_filter( params[:tab] ).page( params[:page] ).
            per( HardSettings.profile_pagination_entries ).
            order( 'id DESC' )

        @counts = {}
        %w(yours shared global).each do |type|
            @counts[type] = profile_filter( type ).count
        end

        @counts['others'] = profile_filter( 'others' ).count if current_user.admin?
    end

end
