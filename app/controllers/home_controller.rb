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

class HomeController < ApplicationController
    include ApplicationHelper
    include NavigationHelper

    before_filter :authenticate_user!

    def index
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
