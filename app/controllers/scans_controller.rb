class ScansController < ApplicationController
    before_filter :authenticate_user!

    include ScansHelper
    include ApplicationHelper
    include NotificationsHelper

    load_and_authorize_resource

    # GET /scans
    # GET /scans.json
    def index
        params[:filter_finished] ||= params[:filter_active] ||= 'yours'

        @counts = {
            active: {},
            finished: {}
        }
        %w(yours shared others).each do |type|
            begin
                @counts[:active][type] = scan_filter( type ).
                    light.active.count

                @counts[:active]['total'] ||= 0
                @counts[:active]['total']  += @counts[:active][type]

                @counts[:finished][type] = scan_filter( type ).
                    light.finished.count

                @counts[:finished]['total'] ||= 0
                @counts[:finished]['total']  += @counts[:finished][type]
            rescue
            end

        end

        @active_scans = scan_filter( params[:filter_active] ).active.
            page( params[:active_page] ).
            per( Settings.active_scan_pagination_entries ).order( 'id DESC' )

        @finished_scans = scan_filter( params[:filter_finished] ).finished.light.
            page( params[:finished_page] ).
            per( Settings.finished_scan_pagination_entries ).order( 'id DESC' )

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
        @scan = find_scan( params[:id], false )

        html_block = if render_partial?
                         proc { render @scan }
                     end

        respond_to do |format|
            format.html( &html_block )
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
                           framework { |f| f.report_as format, @scan.report }
    end

    # GET /scans/new
    # GET /scans/new.json
    def new
        @profiles = Profile.all
        @scan     = Scan.new

        @dispatchers      = Dispatcher.alive
        @grid_dispatchers = @dispatchers.grid_members

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @scan }
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

    # PUT /scans/1
    # PUT /scans/1.json
    def update
        @scan = find_scan( params[:id] )

        if params[:scan][:user_ids]
            params[:scan][:user_ids] |= [@scan.owner.id]
        end

        respond_to do |format|
            if @scan.update_attributes( params[:scan] )

                notify @scan, action: params[:scan].include?( :user_ids ) ?
                                        'shared' : params[:action]

                format.html { redirect_to :back, notice: 'Scan was successfully updated.' }
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

        redirect_to :back, notice: 'Scan is being paused.'
    end

    # PUT /scans/1/resume
    def resume
        @scan = find_scan( params[:id] )
        @scan.resume

        notify @scan

        redirect_to :back, notice: 'Scan is resuming.'
    end

    # PUT /scans/1/abort
    def abort
        @scan = find_scan( params[:id] )
        @scan.abort

        notify @scan

        redirect_to :back, notice: 'Scan is being aborted.'
    end

    # DELETE /scans/1
    # DELETE /scans/1.json
    def destroy
        @scan = find_scan( params[:id] )
        @scan.destroy

        notify @scan

        respond_to do |format|
            format.html { redirect_to scans_url }
            format.json { head :no_content }
        end
    end

    private

    def find_scan( id, light = true )
        s = (current_user.admin? ? Scan : current_user.scans)
        s = s.light if light
        s.find( params[:id] )
    end

end
