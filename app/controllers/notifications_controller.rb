=begin
    Copyright 2013-2014 Tasos Laskos <tasos.laskos@arachni-scanner.com>

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

class NotificationsController < ApplicationController
    load_and_authorize_resource

    ## GET /notifications
    ## GET /notifications.json
    #def index
    #    @notifications = current_user.notifications
    #
    #    respond_to do |format|
    #        format.html # index.html.erb
    #        format.json { render json: @notifications }
    #    end
    #end
    #
    ## GET /notifications/1
    ## GET /notifications/1.json
    #def show
    #    @notification = current_user.notifications.find( params[:id] )
    #
    #    respond_to do |format|
    #        format.html # show.html.erb
    #        format.json { render json: @notification }
    #    end
    #end

    # PUT /notifications/mark_all_read
    def mark_read
        current_user.notifications.mark_read

        respond_to do |format|
            format.html { redirect_to :back }
            format.js
        end
    end

    # DELETE /notifications/1
    # DELETE /notifications/1.json
    def destroy
        @notification = current_user.notifications.find( params.require( :id ) )
        @notification.destroy

        respond_to do |format|
            format.html { redirect_to notifications_url }
            format.json { head :no_content }
        end
    end
end
