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

class UsersController < ApplicationController
    before_filter :authenticate_user!
    before_filter :new_user, only: [ :create ]

    load_and_authorize_resource

    def index
        @users = User.order( 'id desc' ).all
    end

    def show
        @user       = User.find( params.require( :id ) )
        @scans      = @user.own_scans.select { |s| can? :read, s }
        @activities = @user.activities.page( params[:activities_page] ).
                        per( HardSettings.activities_pagination_entries ).
                        order( 'id DESC' )
    end

    def new
        @user = User.new

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @user }
        end
    end

    def edit
        @user = User.find( params.require( :id ) )
    end

    def create
        respond_to do |format|
            if @user.save
                format.html { redirect_to @user, notice: 'User was successfully created.' }
                format.json { render json: @user, status: :created, location: @user }
            else
                format.html { render action: "new" }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end

    def update
        @user = User.find( params.require( :id ) )

        respond_to do |format|
            if @user.update_attributes( strong_params )
                format.html { redirect_to :back, notice: 'User was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end

    def destroy
        @user = User.find( params.require( :id ) )

        @user.destroy

        respond_to do |format|
            format.html { redirect_to users_url }
            format.json { head :no_content }
        end
    end

    private

    def new_user
        @user = User.new( strong_params )
    end

    def strong_params
        if params[:user][:password].blank?
            params[:user].delete(:password)
            params[:user].delete(:password_confirmation)
        end

        if current_user.admin?
            params.require( :user ).
                permit( :name, :email, :password, :password_confirmation,
                        :remember_me, { role_ids: [] } )
        else
            params.require( :user ).
                permit( :name, :email, :password, :password_confirmation,
                        :remember_me )
        end
    end

end
