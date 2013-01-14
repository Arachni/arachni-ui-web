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

class UsersController < ApplicationController
    include NotificationsHelper
    before_filter :authenticate_user!

    load_and_authorize_resource

    def index
        @users = User.all
    end

    def show
        @user = User.find( params[:id] )
    end

    def new
        @user = User.new

        respond_to do |format|
            format.html # new.html.erb
            format.json { render json: @user }
        end
    end

    def edit
        @user = User.find(params[:id])
    end

    def create
        @user = User.new(params[:user])

        if params[:user][:password].blank?
            params[:user].delete(:password)
            params[:user].delete(:password_confirmation)
        end

        params[:user].delete( :role_ids ) if !current_user.admin?

        respond_to do |format|
            if @user.save

                notify @user

                format.html { redirect_to @user, notice: 'User was successfully created.' }
                format.json { render json: @user, status: :created, location: @user }
            else
                format.html { render action: "new" }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end

    def update
        if params[:user][:password].blank?
            params[:user].delete( :password )
            params[:user].delete( :password_confirmation )
        end

        params[:user].delete( :role_ids ) if !current_user.admin?

        @user = User.find(params[:id])

        respond_to do |format|
            if @user.update_attributes(params[:user])

                notify @user

                format.html { redirect_to :back, notice: 'User was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @user.errors, status: :unprocessable_entity }
            end
        end
    end

    def destroy
        @user = User.find( params[:id] )

        notify @user

        @user.destroy

        respond_to do |format|
            format.html { redirect_to users_url }
            format.json { head :no_content }
        end
    end

end
