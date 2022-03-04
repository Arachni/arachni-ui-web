=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class ScanGroupsController < ApplicationController
    include ScanGroupsHelper
    include ScansHelper

    before_action :authenticate_user!

    # Watch out, sets @scan_group to an empty group as a fail-safe.
    before_action :set_selected_group, only: [:new, :edit, :create, :update, :destroy]

    before_action :new_scan_group, only: [ :create ]
    before_action :set_scan_group, only: [:edit, :update, :destroy]

    load_and_authorize_resource

    # GET /scan_groups/new
    def new
        respond_to do |format|
            format.js { render '_form_with_list.js' }
        end
    end

    # GET /scan_groups/1/edit
    def edit
        respond_to do |format|
            format.js { render '_form_with_list.js' }
        end
    end

    # POST /scan_groups
    def create
        @scan_group.owner = current_user

        @scan_group = ScanGroup.new if @scan_group.save

        respond_to do |format|
            format.js { render '_form_with_list.js' }
        end
    end

    # PATCH/PUT /scan_groups/1
    def update
        @scan_group = ScanGroup.new if @scan_group.update( strong_params )
        respond_to do |format|
            format.js { render '_form_with_list.js' }
        end
    end

    # DELETE /scan_groups/1
    def destroy
        @scan_group.destroy
        @scan_group = ScanGroup.new

        respond_to do |format|
            format.js { render '_form_with_list.js' }
        end
    end

    private

    def new_scan_group
        @scan_group = ScanGroup.new( strong_params )
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_scan_group
        @scan_group = ScanGroup.find( params[:id] )
    end

    def set_selected_group
        prepare_scan_group_tab_data
        @group = ScanGroup.find_by_id( params[:selected_group_id] ) if params[:selected_group_id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def strong_params
        params.require( :scan_group ).permit( :name, :description, { user_ids: [] } )
    end
end
