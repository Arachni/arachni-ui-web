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

class ScansController < ApplicationController
    include ScansHelper
    include ApplicationHelper
    include NotificationsHelper

    before_filter :authenticate_user!

    # Prevents CanCan throwing ActiveModel::ForbiddenAttributesError when calling
    # load_and_authorize_resource.
    before_filter :new_scan, only: [ :create ]

    load_and_authorize_resource

    # GET /scans
    # GET /scans.json
    def index
        prepare_tables_data

        respond_to do |format|
            format.html # index.html.erb
            format.js { render '_tables.js' }
            format.json { render json: @scans }
        end
    end

    def errors
        @scan = find_scan( params.require( :id ) )

        respond_to do |format|
            format.text
        end
    end

    # GET /scans/1
    # GET /scans/1.json
    def show
        @scan = find_scan( params.require( :id ) )

        html_block = if render_partial?
                         proc { render @scan }
                     end

        respond_to do |format|
            format.html( &html_block )
            format.js { render '_scan.js' }
            format.json { render json: @scan }
        end
    end

    # GET /scans/1/report.html
    # GET /scans/1/report.json
    def report
        @scan = find_scan( params.require( :id ), false )

        format = URI( request.url ).path.split( '.' ).last
        render layout: false,
               text: FrameworkHelper.
                           framework { |f| f.report_as format, @scan.report.object }
    end

    # GET /scans/new
    # GET /scans/new.json
    def new
        @profiles = Profile.all

        html_proc = nil
        if params[:id]
            html_proc = proc { render '_revision_form' }
            @scan = find_scan( params.require( :id ) )
        else
            @scan = Scan.new
        end

        @dispatchers      = Dispatcher.alive
        @grid_dispatchers = @dispatchers.grid_members

        respond_to do |format|
            format.html( &html_proc )
            format.json { render json: @scan }
        end
    end

    # GET /scans/new/1
    def new_revision
        @scan = find_scan( params.require( :id ) )

        @dispatchers      = Dispatcher.alive
        @grid_dispatchers = @dispatchers.grid_members

        respond_to do |format|
            format.html
        end
    end

    # POST /scans
    # POST /scans.json
    def create
        @profiles = Profile.all

        @dispatchers      = Dispatcher.alive
        @grid_dispatchers = @dispatchers.grid_members

        @scan.owner = current_user
        @scan.users |= [current_user]

        respond_to do |format|
            if @scan.save
                notify @scan

                format.html { redirect_to @scan }
                format.json { render json: @scan, status: :created, location: @scan }
            else
                format.html { render action: "new" }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # POST /scans/1/repeat
    def repeat
        @scan = find_scan( params.require( :id ) ).new_revision

        respond_to do |format|
            if @scan.repeat( strong_params )
                notify @scan

                format.html { redirect_to @scan, notice: 'Repeating the scan.' }
                format.json { render json: @scan, status: :created, location: @scan }
            else
                format.html { render action: "new" }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /scans/1
    # PUT /scans/1.json
    def update
        @scan = find_scan( params.require( :id ) )

        respond_to do |format|
            if @scan.update_attributes( params.require( :scan ).permit( :description ) )
                format.html { redirect_to :back, notice: 'Scan was successfully updated.' }
                format.js { render '_scan.js' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.js { render '_scan.js' }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    def share
        @scan = find_scan( params.require( :id ) )

        respond_to do |format|
            if @scan.share( params.require( :scan ).permit( user_ids: [] )[:user_ids] )

                notify @scan

                format.html { redirect_to :back, notice: 'Scan was successfully shared.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /scans/1/pause
    def pause
        @scan = find_scan( params.require( :id ) )
        @scan.pause

        notify @scan

        respond_to do |format|
            format.js {
                if params[:render] == 'index'
                    prepare_tables_data
                    render '_tables.js'
                else
                    render '_scan.js'
                end
            }
        end
    end

    # PUT /scans/1/resume
    def resume
        @scan = find_scan( params.require( :id ) )
        @scan.resume

        notify @scan

        respond_to do |format|
            format.js {
                if params[:render] == 'index'
                    prepare_tables_data
                    render '_tables.js'
                else
                    render '_scan.js'
                end
            }
        end
    end

    # PUT /scans/1/abort
    def abort
        @scan = find_scan( params.require( :id ) )
        @scan.abort

        notify @scan

        respond_to do |format|
            format.js {
                if params[:render] == 'index'
                    prepare_tables_data
                    render '_tables.js'
                else
                    render '_scan.js'
                end
            }
        end
    end

    # DELETE /scans/1
    # DELETE /scans/1.json
    def destroy
        @scan = find_scan( params.require( :id ) )

        if @scan.active?
            fail 'Cannot delete an active scan, please abort it first.'
        end

        @scan.destroy
        notify @scan

        respond_to do |format|
            format.html { redirect_to scans_url }
            format.js {
                prepare_tables_data
                render '_tables.js'
            }
        end
    end

    private

    def new_scan
        @scan = Scan.new( strong_params )
    end

    def strong_params
        if params[:scan][:type] == 'grid' || params[:scan][:type] == 'remote'
            params[:scan][:dispatcher_id] = params.delete( params[:scan][:type].to_s + '_dispatcher_id' )
        end

        if sitemap_option = params[:scan].delete( :sitemap_option )
            params[:scan][sitemap_option] = true
        end

        params.delete( 'grid_dispatcher_id' )
        params.delete( 'remote_dispatcher_id' )

        ap params

        params.require( :scan ).
            permit( :url, :description, :type, :instance_count, :profile_id,
                    { user_ids: [] }, :dispatcher_id, :restrict_to_revision_sitemaps,
                    :extend_from_revision_sitemaps ).tap { |t| ap t }
    end

    def find_scan( id, light = true )
        s = (current_user.admin? ? Scan : current_user.scans)
        s = s.light if light
        s = s.find( params[:id] )

        params[:overview] == 'true' ? s.act_as_overview : s
    end

end
