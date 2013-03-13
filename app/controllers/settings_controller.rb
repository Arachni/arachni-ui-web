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

class SettingsController < ApplicationController
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
            permit( :scan_global_limit, :scan_per_user_limit, {scan_allowed_types: []},
                    :scan_target_whitelist_patterns, :scan_target_blacklist_patterns )
    end
end
