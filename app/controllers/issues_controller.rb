=begin
    Copyright 2010-2012 Tasos Laskos <tasos.laskos@gmail.com>

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

class IssuesController < ApplicationController
    include ApplicationHelper
    include NotificationsHelper

    load_and_authorize_resource

    # GET /issues
    # GET /issues.json
    def index
        @scan   = scan
        @issues = scan.sorted_issues

        html_block =    if render_partial?
                            proc { render partial: 'table' }
                        else
                            proc { redirect_to scan }
                        end

        respond_to do |format|
            format.html( &html_block )
            format.json { render json: @issues }
        end
    end

    # GET /issues/1
    # GET /issues/1.json
    def show
        @issue = scan.issues.find( params[:id] )

        respond_to do |format|
            format.html # show.html.erb
            format.json { render json: @issue }
        end
    end

    # PUT /issues/1
    # PUT /issues/1.json
    def update
        @issue = scan.issues.find( params[:id] )

        was_verified = @issue.verified?

        respond_to do |format|
            if @issue.update_attributes( params[:issue] )

                if !was_verified && @issue.verified?
                    notify @issue, action: 'verified'
                else
                    notify @issue
                end

                format.html { redirect_to [@issue.scan, @issue],
                                          notice: 'Issue was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @issue.errors,
                                     status: :unprocessable_entity }
            end
        end
    end

    # DELETE /issues/1
    # DELETE /issues/1.json
    def destroy
        @issue = scan.issues.find( params[:id] )
        @issue.destroy

        respond_to do |format|
            format.html { redirect_to scans_issues_url }
            format.json { head :no_content }
        end
    end

    private

    def scan
        current_user.scans.find( params[:scan_id] )
    end

end
