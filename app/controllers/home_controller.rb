=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class HomeController < ApplicationController
    include ApplicationHelper
    include NavigationHelper

    before_action :authenticate_user!

    def index
        params.permit!

        @activities    = current_user.activities.page( params[:activities_page] ).
            per( HardSettings.activities_pagination_entries ).order( 'id DESC' )

        @notifications = current_user.notifications.page( params[:notifications_page] ).
            per( HardSettings.notifications_pagination_entries ).order( 'id DESC' )

        @issues_per_scan = {}
        current_user.scans.each { |s| @issues_per_scan[s.id] = s.issues.count }

        html_block = if render_partial?
                         proc { render partial: 'dashboard' }
                     end

        respond_to do |format|
            format.html( &html_block )
            format.js {
                if params[:render] == 'activities'
                    render '_activities.js.erb'
                elsif params[:render] == 'notifications'
                    render partial: 'notifications.js.erb'
                end
            }
        end
    end

    def navigation
        respond_to do |format|
            format.html { render partial: 'layouts/navigation' }
        end
    end

end
