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

class ProfilesController < ApplicationController
    include ProfilesHelper
    include NotificationsHelper

    before_filter :authenticate_user!
    before_filter :prepare_plugin_params
    before_filter :new_profile, only: [ :create ]

    load_and_authorize_resource

    # GET /profiles
    # GET /profiles.json
    def index
        prepare_table_data

        respond_to do |format|
            format.html # index.html.erb
            format.js { render '_table.js' }
            format.json { render json: @profiles }
        end
    end

    # GET /profiles/1
    # GET /profiles/1.json
    def show
        @profile = Profile.find( params.require( :id ) )

        respond_to do |format|
            format.html # show.html.erb
            format.js { render @profile }
            format.json { render json: @profile }
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
        @profile.owner  = current_user
        @profile.users |= [current_user]

        respond_to do |format|
            if @profile.save
                notify @profile

                format.html { redirect_to @profile, notice: 'Profile was successfully created.' }
                format.json { render json: @profile, status: :created, location: @profile }
            else
                format.html { render action: "new" }
                format.json { render json: @profile.errors, status: :unprocessable_entity }
            end
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

                format.html { redirect_to :back, notice: 'Profile was successfully shared.' }
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
        fail 'Cannot delete default profile.' if @profile.default?

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
        allowed = [:name, :audit_cookies, :audit_cookies_extensively, :audit_forms,
                   :audit_headers, :audit_links, :authed_by, :auto_redundant,
                   :cookies, :custom_headers, :depth_limit, :exclude,
                   :exclude_binaries, :exclude_cookies, :exclude_vectors,
                   :extend_paths, :follow_subdomains, :fuzz_methods, :http_req_limit,
                   :include, :link_count_limit, :login_check_pattern, :login_check_url,
                   :max_slaves, :min_pages_per_instance, { modules: [] }, { selected_plugins: []},
                   { plugins: {}}, :proxy_host, :proxy_password, :proxy_port,
                   :proxy_type, :proxy_username, :redirect_limit, :redundant,
                   :restrict_paths, :user_agent, :http_timeout, :description,
                   :https_only, :exclude_pages, { user_ids: [] }]

        allowed << :global if current_user.admin?

        params.require( :profile ).permit( *allowed )
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
            per( Settings.profile_pagination_entries ).
            order( 'id DESC' )

        @counts = {}
        %w(yours shared global).each do |type|
            @counts[type] = profile_filter( type ).count
        end

        @counts['others'] = profile_filter( 'others' ).count if current_user.admin?
    end

end
