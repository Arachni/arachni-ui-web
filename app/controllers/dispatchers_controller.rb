=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class DispatchersController < ApplicationController
    include ApplicationHelper
    include NotificationsHelper
    include DispatchersHelper

    before_action :authenticate_user!
    before_action :new_dispatcher, only: [ :create ]

    load_and_authorize_resource

    # GET /dispatchers
    # GET /dispatchers.json
    def index
        params.permit!
        prepare_table_data

        html_block = if render_partial?
                         proc { render partial: 'tables' }
                     end

        respond_to do |format|
            format.html( &html_block )
            format.js { render '_tables.js' }
            format.json { render json: @dispatchers }
        end
    end

    # GET /dispatchers/1
    # GET /dispatchers/1.json
    def show
        @dispatcher = Dispatcher.find( params.require( :id ) )

        html_block = if render_partial?
                         proc { render @dispatcher }
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
        @dispatcher = Dispatcher.find( params.require( :id ) )
    end

    # POST /dispatchers
    # POST /dispatchers.json
    def create
        @dispatcher.owner = current_user

        respond_to do |format|
            if @dispatcher.save
                notify @dispatcher

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

    # PUT /profiles/1/make_default
    def make_default
        dispatcher = Dispatcher.find( params.require( :id ) )

        fail 'Cannot make a non-global dispatcher the default one.' if !dispatcher.global?

        dispatcher.make_default
        params.delete( :id )

        notify dispatcher

        prepare_table_data
        render partial: 'tables', formats: :js
    end

    # PUT /dispatchers/1
    # PUT /dispatchers/1.json
    def update
        @dispatcher = Dispatcher.find( params.require( :id ) )

        respond_to do |format|
            if @dispatcher.update_attributes( strong_params )
                notify @dispatcher

                format.html { redirect_to @dispatcher, notice: 'Dispatcher was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @dispatcher.errors, status: :unprocessable_entity }
            end
        end
    end

    def share
        @dispatcher = Dispatcher.find( params.require( :id ) )

        respond_to do |format|
            if @dispatcher.update_attributes( params.require( :dispatcher ).permit( user_ids: [] ) )
                notify @dispatcher

                format.html { redirect_back fallback_location: dispatchers_path, notice: 'Dispatcher was successfully shared.' }
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
        @dispatcher = Dispatcher.find( params.require( :id ) )

        if @dispatcher.has_scheduled_scans?
            fail 'Cannot delete a Dispatcher assigned to scheduled Scans.'
        end

        notify @dispatcher

        @dispatcher.destroy

        respond_to do |format|
            format.html { redirect_to dispatchers_url }
            format.json { head :no_content }
        end
    end

    private

    def new_dispatcher
        @dispatcher = Dispatcher.new( strong_params )
    end

    def strong_params
        allowed = [ :address, :port, :description, { user_ids: [] } ]
        allowed << :global if current_user.admin?

        params.require( :dispatcher ).permit( *allowed )
    end

    def prepare_table_data
        params[:alive_tab] ||= params[:unreachable_tab] ||= 'yours'

        @counts = {
            alive:       {},
            unreachable: {}
        }
        %w(yours shared others global).each do |type|
            begin
                @counts[:alive][type] = dispatcher_filter( type ).alive.count

                @counts[:alive]['total'] ||= 0
                @counts[:alive]['total']  += @counts[:alive][type]

                @counts[:unreachable][type] = dispatcher_filter( type ).unreachable.count

                @counts[:unreachable]['total'] ||= 0
                @counts[:unreachable]['total']  += @counts[:unreachable][type]
            rescue
            end
        end

        @alive_dispatchers = dispatcher_filter( params[:alive_tab] ).
            page( params[:page] ).
            per( HardSettings.dispatcher_pagination_entries ).
            alive.
            order( 'id DESC' )

        @unreachable_dispatchers = dispatcher_filter( params[:unreachable_tab] ).
            page( params[:page] ).
            per( HardSettings.dispatcher_pagination_entries ).
            unreachable.
            order( 'id DESC' )
    end

end
