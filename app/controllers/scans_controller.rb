=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class ScansController < ApplicationController
    include ScansHelper
    include ScanGroupsHelper
    include ApplicationHelper
    include NotificationsHelper

    rescue_from ActiveRecord::RecordNotFound do
        flash[:alert] = 'The requested scan does not exist or has been deleted.'

        respond_to do |format|
            format.html { redirect_to :scans }
            format.js { render text: "window.location = '#{scans_path}';" }
        end
    end

    before_action :authenticate_user!

    before_action :prepare_associations,
                  only: [ :new, :new_revision, :create, :repeat, :update, :edit ]

    # Prevents CanCan throwing ActiveModel::ForbiddenAttributesError when calling
    # load_and_authorize_resource.
    before_action :new_scan, only: [ :create, :import ]

    before_action :check_scan_type_abilities, only: [ :create, :repeat ]

    load_and_authorize_resource

    # GET /scans
    # GET /scans.json
    def index
        params.permit!
        prepare_scan_group_tab_data
        prepare_tables_data

        respond_to do |format|
            format.html # index.html.erb
            format.js { render '_tables.js' }
            format.json { render json: @scans }
        end
    end

    # GET /scans/schedule
    # GET /scans/schedule.json
    def schedule
        params.permit!
        prepare_scan_group_tab_data
        prepare_schedule_data

        respond_to do |format|
            format.html # index.html.erb
            format.js { render 'schedule.js' }
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
        params.permit!

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
        @scan = find_scan( params.require( :id ) )

        name = "#{URI( @scan.url ).host} - #{@scan.profile.name} - #{@scan.id}".
            gsub( '/', '_' ).gsub( '.', '_' ).gsub( "\n", '' ).gsub( "\r", '' )

        format = URI( request.url ).path.split( '.' ).last

        if format == 'afr'
            report    = @scan.report.object.to_afr
            extension = 'afr'
        else
            report    = FrameworkHelper.framework { |f| f.report_as format, @scan.report.object }
            extension = FrameworkHelper.reporters[format][:extension]
        end

        send_data report,
                  type: FrameworkHelper.content_type_for_report( format ),
                  disposition: "attachment; filename=\"#{name}.#{extension}\""
    end

    # GET /scans/new
    # GET /scans/new.json
    def new
        show_scan_limit_errors

        html_proc = nil
        if params[:id]
            html_proc = proc { render '_revision_form' }
            @scan = find_scan( params.require( :id ) )
        else
            @scan = Scan.new
            @scan.build_schedule
        end

        respond_to do |format|
            format.html( &html_proc )
            format.json { render json: @scan }
        end
    end

    # GET /scans/1/edit
    def edit
        @scan = find_scan( params.require( :id ) )
    end

    # GET /scans/new/1
    def new_revision
        @scan = find_scan( params.require( :id ) )

        fail 'Scan has no Profile, cannot repeat.' if !@scan.profile

        respond_to do |format|
            format.html
        end
    end

    # POST /scans
    # POST /scans.json
    def create
        show_scan_limit_errors

        @scan.owner = current_user

        respond_to do |format|
            if !Scan.limit_exceeded? && @scan.save

                ScanManager.process @scan

                if @scan.scheduled?
                    notify @scan, action: :scheduled
                else
                    notify @scan
                end

                format.html { redirect_to @scan }
                format.json { render json: @scan, status: :created, location: @scan }
            else
                format.html { render action: "new" }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # POST /scans/import
    def import
        if !params[:scan] ||
            !((file = params[:scan][:file]).is_a?( ActionDispatch::Http::UploadedFile ))

            redirect_to scans_url, alert: 'No file selected for import.'
            return
        end

        begin
            scan = Scan.import( current_user, file )
        rescue => e
            redirect_to scans_url,
                        alert: "Report could not be imported because: [#{e.class}] #{e}"
            return
        end

        respond_to do |format|
            format.html { redirect_to scan }
        end
    end

    # POST /scans/1/repeat
    def repeat
        show_scan_limit_errors

        @scan = find_scan( params.require( :id ) ).new_revision
        update_params   = strong_params( @scan )
        schedule_params = update_params.delete(:schedule)

        respond_to do |format|
            if @scan.repeat( update_params ) &&
                @scan.schedule.update_attributes( schedule_params )

                ScanManager.process @scan
                notify @scan

                format.html { redirect_to @scan, notice: 'Repeating the scan.' }
                format.json { render json: @scan, status: :created, location: @scan }
            else
                if errors = @scan.errors.delete( :url )
                    flash[:error] = "URL #{errors.first}."
                end
                format.html { redirect_to new_revision_scan_url( Scan.find( params[:id] ) ) }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /scans/1
    # PUT /scans/1.json
    def update
        @scan = find_scan( params.require( :id ) )

        update_params   = strong_params( @scan )
        schedule_params = update_params.delete(:schedule) || {}

        respond_to do |format|
            if @scan.update_attributes( update_params ) &&
                @scan.schedule.update_attributes( schedule_params )

                format.html { redirect_back fallback_location: scans_path, notice: 'Scan was successfully updated.' }
                format.js { render '_scan.js' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.js { render '_scan.js' }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    def update_memberships
        @scan = find_scan( params.require( :id ) )

        scan_group_ids = params.require( :scan ).
            permit( scan_group_ids: [] )[:scan_group_ids]

        respond_to do |format|
            if @scan.update_memberships( scan_group_ids )

                text = ''
                if !(group_names = @scan.scan_groups.pluck( :name ).join( ', ')).empty?
                    text = "Member of: #{group_names}"
                else
                    text = 'Left all groups.'
                end

                notify @scan, text: text

                format.html { redirect_back fallback_location: scans_path, notice: 'Scan was successfully shared.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    def share
        @scan = find_scan( params.require( :id ) )

        respond_to do |format|
            if @scan.share( params.require( :scan ).permit( user_ids: [] )[:user_ids] )

                notify @scan

                format.html { redirect_back fallback_location: scans_path, notice: 'Scan was successfully shared.' }
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
                    prepare_scan_group_tab_data
                    prepare_tables_data
                    render '_tables.js'
                else
                    render '_scan.js'
                end
            }
        end
    end

    # PATCH /scans/pause
    def pause_all
        current_user.own_scans.running.each do |scan|
            scan.pause
            notify scan
        end

        respond_to do |format|
            format.js {
                prepare_scan_group_tab_data
                prepare_tables_data
                render '_tables.js'
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
                    prepare_scan_group_tab_data
                    prepare_tables_data
                    render '_tables.js'
                else
                    render '_scan.js'
                end
            }
        end
    end

    # PATCH /scans/resume
    def resume_all
        current_user.own_scans.paused.each do |scan|
            scan.resume
            notify scan
        end

        respond_to do |format|
            format.js {
                prepare_scan_group_tab_data
                prepare_tables_data
                render '_tables.js'
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
                    prepare_scan_group_tab_data
                    prepare_tables_data
                    render '_tables.js'
                else
                    render '_scan.js'
                end
            }
        end
    end

    # PATCH /scans/abort
    def abort_all
        current_user.own_scans.active.each do |scan|
            scan.abort
            notify scan
        end

        respond_to do |format|
            format.js {
                prepare_scan_group_tab_data
                prepare_tables_data
                render '_tables.js'
            }
        end
    end

    # PUT /scans/1/suspend
    def suspend
        @scan = find_scan( params.require( :id ) )

        fail 'Cannot suspend a multi-Instance scan.' if @scan.spawns > 0
        @scan.suspend

        notify @scan

        respond_to do |format|
            format.js {
                if params[:render] == 'index'
                    prepare_scan_group_tab_data
                    prepare_tables_data
                    render '_tables.js'
                else
                    render '_scan.js'
                end
            }
        end
    end

    # PATCH /scans/abort
    def suspend_all
        current_user.own_scans.active.each do |scan|
            scan.suspend
            notify scan
        end

        respond_to do |format|
            format.js {
                prepare_scan_group_tab_data
                prepare_tables_data
                render '_tables.js'
            }
        end
    end

    # PUT /scans/1/restore
    def restore
        @scan = find_scan( params.require( :id ) )
        fail 'Scan not suspended.' if !@scan.suspended?

        ScanManager.restore @scan
        notify @scan

        respond_to do |format|
            format.js {
                if params[:render] == 'index'
                    prepare_scan_group_tab_data
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

    def prepare_associations
        @profiles         = current_user.available_profiles
        @dispatchers      = current_user.available_dispatchers.alive
        @grid_dispatchers = @dispatchers.grid_members
    end

    def new_scan
        parameters = strong_params
        schedule   = parameters.delete( 'schedule' )

        @scan = Scan.new( parameters )
        @scan.create_schedule( schedule )
    end

    def strong_params( scan = nil )
        if params[:scan][:type] == 'grid' || params[:scan][:type] == 'remote'
            params[:scan][:dispatcher_id] =
                params.delete( params[:scan][:type].to_s + '_dispatcher_id' )
        end

        params[:scan][:load_balance] = (params[:scan][:dispatcher_id] == 'load_balance')

        allowed = [ :restrict_to_revision_sitemaps, :extend_from_revision_sitemaps ]
        if (sitemap_option = params[:scan].delete( :sitemap_option )) &&
            allowed.include?( sitemap_option.to_sym )
            params[:scan][sitemap_option] = true
        end

        if params[:scan][:schedule] && params[:scan][:schedule][:stop_after]
            params[:scan][:schedule][:stop_after] =
                Arachni::Utilities.hms_to_seconds( params[:scan][:schedule][:stop_after] )
        end

        params.delete( 'grid_dispatcher_id' )
        params.delete( 'remote_dispatcher_id' )

        allowed_params = [ :description, { user_ids: [] }, { scan_group_ids: [] },
            :restrict_to_revision_sitemaps, :extend_from_revision_sitemaps ]

        if !scan || (!scan.active? && !scan.finished?)
            allowed_params += [ :type, :instance_count, :profile_id, :dispatcher_id, :load_balance ]
        end

        if !scan || !scan.finished?
            allowed_params << {
                schedule: [ :start_at, :every_minute, :every_hour, :every_day,
                            :every_month, :basetime, :stop_after, :stop_suspend ]
            }
        end

        if !scan || !scan.id
            allowed_params << :url
        end

        params.require( :scan ).permit( allowed_params )
    end

    def find_scan( id )
        s = Scan.find( params[:id] )
        params[:overview] == 'true' ? s.act_as_overview : s
    end

    def check_scan_type_abilities
        return if can? "perform_#{params[:scan][:type]}".to_sym, Scan

        flash[:error] = "You don't have #{params[:scan][:type]} scan privileges."
        redirect_back fallback_location: scans_path
    end

    def show_scan_limit_errors
        if Scan.limit_exceeded?
            do_not_fade_out_messages
            flash[:error] = 'Maximum scan limit has been reached, please try again later.'
        end

        if current_user.scan_limit_exceeded?
            do_not_fade_out_messages
            flash[:error] = 'Your scan limit has been reached, please try again later.'
        end
    end

end
