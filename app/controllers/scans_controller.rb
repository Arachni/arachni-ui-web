class ScansController < ApplicationController
    include ScansHelper
    include ApplicationHelper
    include NotificationsHelper

    before_filter :authenticate_user!

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
        @scan = find_scan( params[:id] )

        respond_to do |format|
            format.text
        end
    end

    # GET /scans/1
    # GET /scans/1.json
    def show
        @scan = find_scan( params[:id] )

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
        @scan = find_scan( params[:id], false )

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
            @scan = find_scan( params[:id] )
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
        @scan = find_scan( params[:id] )

        @dispatchers      = Dispatcher.alive
        @grid_dispatchers = @dispatchers.grid_members

        respond_to do |format|
            format.html
        end
    end

    # POST /scans
    # POST /scans.json
    def create
        if params[:scan][:type] == 'grid' || params[:scan][:type] == 'remote'
            params[:scan][:dispatcher_id] = params.delete( params[:scan][:type].to_s + '_dispatcher_id' )
        end

        params.delete( 'grid_dispatcher_id' )
        params.delete( 'remote_dispatcher_id' )

        @scan     = Scan.new( params[:scan] )
        @profiles = Profile.all

        @dispatchers      = Dispatcher.alive
        @grid_dispatchers = @dispatchers.grid_members

        @scan.owner = current_user
        @scan.users |= [current_user]

        respond_to do |format|
            if @scan.save
                notify @scan

                format.html { redirect_to @scan, notice: 'Scan was successfully created.' }
                format.json { render json: @scan, status: :created, location: @scan }
            else
                format.html { render action: "new" }
                format.json { render json: @scan.errors, status: :unprocessable_entity }
            end
        end
    end

    # POST /scans/1/repeat
    def repeat
        opts = params[:scan].dup

        if sitemap_option = opts.delete( :sitemap_option )
            opts[sitemap_option] = true
        end

        @scan = find_scan( params[:id] ).new_revision

        respond_to do |format|
            if @scan.repeat( opts )
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
        @scan = find_scan( params[:id] )

        respond_to do |format|
            if @scan.update_attributes( params[:scan] )
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
        @scan = find_scan( params[:id] )

        respond_to do |format|
            if @scan.share( params[:scan][:user_ids] )

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
        @scan = find_scan( params[:id] )
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
        @scan = find_scan( params[:id] )
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
        @scan = find_scan( params[:id] )
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
        @scan = find_scan( params[:id] )
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

    def find_scan( id, light = true )
        s = (current_user.admin? ? Scan : current_user.scans)
        s = s.light if light
        s = s.find( params[:id] )

        params[:overview] == 'true' ? s.act_as_overview : s
    end

end
