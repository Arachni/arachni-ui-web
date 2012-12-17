class ScansController < ApplicationController
    before_filter :authenticate_user!

    # GET /scans
    # GET /scans.json
    def index
        @active_scans   = current_user.scans.active.light.reverse
        @finished_scans = current_user.scans.finished.light.reverse

        respond_to do |format|
            format.html # index.html.erb
            format.js { render '_tables' }
            format.json { render json: @scans }
        end
    end

    # GET /scans/1
    # GET /scans/1.json
    def show
        @scan = current_user.scans.find(params[:id])

        respond_to do |format|
            format.html # show.html.erb
            format.js { render @scan }
            format.json { render json: @scan }
        end
    end

    # GET /scans/1/report.html
    # GET /scans/1/report.json
    def report
        @scan = current_user.scans.find( params[:id] )

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

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @scan }
        end
    end

    ## GET /scans/1/edit
    #def edit
    #    @scan     = Scan.find( params[:id] )
    #    @profiles = Profile.all
    #end

    # POST /scans
    # POST /scans.json
    def create
        @scan     = Scan.new( params[:scan] )
        @profiles = Profile.all

        @scan.owner = current_user
        @scan.users |= [current_user]

        respond_to do |format|
            if @scan.save
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
        @scan = current_user.scans.light.find( params[:id] )

        fail 'Only the scan owner can do that.' if @scan.owner != current_user

        if params[:scan][:user_ids]
            params[:scan][:user_ids] |= [@scan.owner.id]
        end

        respond_to do |format|
            if @scan.update_attributes( params[:scan] )
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
        @scan = current_user.scans.light.find( params[:id] )

        fail 'Only the scan owner can do that.' if @scan.owner != current_user

        @scan.pause

        redirect_to :back, notice: 'Scan is being paused.'
    end

    # PUT /scans/1/resume
    def resume
        @scan = current_user.scans.light.find( params[:id] )

        fail 'Only the scan owner can do that.' if @scan.owner != current_user

        @scan.resume

        redirect_to :back, notice: 'Scan is resuming.'
    end

    # PUT /scans/1/abort
    def abort
        @scan = current_user.scans.find( params[:id] )

        fail 'Only the scan owner can do that.' if @scan.owner != current_user

        @scan.abort

        redirect_to :back, notice: 'Scan is being aborted.'
    end

    # DELETE /scans/1
    # DELETE /scans/1.json
    def destroy
        @scan = current_user.scans.light.find( params[:id] )

        fail 'Only the scan owner can do that.' if @scan.owner != current_user

        @scan.destroy

        respond_to do |format|
            format.html { redirect_to scans_url }
            format.json { head :no_content }
        end
    end
end
