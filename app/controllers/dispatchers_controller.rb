class DispatchersController < ApplicationController
    include ApplicationHelper

    before_filter :authenticate_user!

    load_and_authorize_resource

    # GET /dispatchers
    # GET /dispatchers.json
    def index
        @alive_dispatchers       = Dispatcher.alive
        @unreachable_dispatchers = Dispatcher.unreachable

        html_block = if render_partial?
                         proc { render partial: 'tables' }
                     end

        respond_to do |format|
            format.html( &html_block )
            format.json { render json: @dispatchers }
        end
    end

    # GET /dispatchers/1
    # GET /dispatchers/1.json
    def show
        @dispatcher = Dispatcher.find(params[:id])

        html_block = if render_partial?
                         proc { render Dispatcher.find( params[:id] ) }
                     end

        respond_to do |format|
            format.html( &html_block )
            format.json { render json: @dispatcher }
        end
    end

    # GET /dispatchers/new
    # GET /dispatchers/new.json
    def new
        @dispatcher = Dispatcher.new

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @dispatcher }
        end
    end

    # GET /dispatchers/1/edit
    def edit
        @dispatcher = Dispatcher.find(params[:id])
    end

    # POST /dispatchers
    # POST /dispatchers.json
    def create
        @dispatcher = Dispatcher.new(params[:dispatcher])

        respond_to do |format|
            if @dispatcher.save
                format.html do
                    redirect_to @dispatcher,
                                notice: 'Dispatcher was successfully created and ' +
                                    'will be available shortly.'
                end
                format.json { render json: @dispatcher, status: :created, location: @dispatcher }
            else
                format.html { render action: "new" }
                format.json { render json: @dispatcher.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /dispatchers/1
    # PUT /dispatchers/1.json
    def update
        @dispatcher = Dispatcher.find(params[:id])

        respond_to do |format|
            if @dispatcher.update_attributes(params[:dispatcher])
                format.html { redirect_to @dispatcher, notice: 'Dispatcher was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @dispatcher.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /dispatchers/1
    # DELETE /dispatchers/1.json
    def destroy
        @dispatcher = Dispatcher.find( params[:id] )

        notify @dispatcher

        @dispatcher.destroy

        respond_to do |format|
            format.html { redirect_to dispatchers_url }
            format.json { head :no_content }
        end
    end
end
