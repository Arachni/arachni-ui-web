=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class SettingsController < ApplicationController
    include ApplicationHelper

    load_and_authorize_resource

    before_action :set_setting, only: [:index, :show, :edit, :update]

    def index
        render :edit
    end
    alias :show :index

    # GET /settings/1/edit
    def edit
    end

    # PATCH/PUT /settings/1
    def update
        if @setting.update( strong_params )
            redirect_to @setting, notice: 'Settings were successfully updated.'
        else
            render action: 'edit'
        end
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_setting
        @setting = Setting.first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def strong_params
        params.require( :setting ).
            permit( :scan_global_limit, :scan_per_user_limit, { scan_allowed_types: [] },
                    { profile_allowed_checks: [] }, { profile_allowed_plugins: [] },
                    :scan_target_whitelist_patterns, :scan_target_blacklist_patterns,
                    :timezone, :scan_auto_refresh )
    end
end
