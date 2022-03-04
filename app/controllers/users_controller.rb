=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :new_user, only: [ :create ]

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
                format.html { redirect_back fallback_location: users_url, notice: 'User was successfully updated.' }
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
