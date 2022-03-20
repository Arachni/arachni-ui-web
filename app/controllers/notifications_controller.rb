=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
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
            format.html { redirect_back fallback_location: root_path }
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
