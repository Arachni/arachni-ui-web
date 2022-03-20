=begin
    Copyright 2013-2022 Ecsypno <http://www.ecsypno.com>

    This file is part of the Arachni WebUI project and is subject to
    redistribution and commercial restrictions. Please see the Arachni WebUI
    web site for more information on licensing and terms of use.
=end

class CommentsController < ApplicationController
    include ApplicationHelper
    include NotificationsHelper

    before_action :authenticate_user!
    before_action :new_comment, only: [ :create ]

    load_and_authorize_resource :scan
    load_and_authorize_resource :comment, through: [:scan]

    ## GET /scan/comments
    ## GET /scan/comments.json
    def index
        @commentable = commentable
        @comments    = @commentable.comments

        html_block = if render_partial?
            proc { render partial: 'list',
                         locals: { comments: commentable.comments,
                                  list_url: polymorphic_path( [@commentable.family, Comment].flatten ) } }
        end

        respond_to do |format|
            format.html( &html_block )
            format.js { render '_list.js' }
            format.json { render json: @comments }
        end
    end

    ## GET /scan/comments/1
    ## GET /scan/comments/1.json
    #def show
    #    @comment = commentable.comments.find( params[:id] )
    #
    #    respond_to do |format|
    #        format.html # show.html.erb
    #        format.json { render json: @comment }
    #    end
    #end
    #
    ## GET /scan/comments/new
    ## GET /scan/comments/new.json
    #def new
    #    @comment = commentable.comments.new
    #
    #    respond_to do |format|
    #        format.html # new.html.erb
    #        format.json { render json: @comment }
    #    end
    #end
    #
    ## GET /scan/comments/1/edit
    #def edit
    #    @comment = Comment.find(params[:id])
    #end

    # POST /scan/comments
    # POST /scan/comments.json
    def create
        @commentable = commentable
        @comment.user = current_user

        respond_to do |format|
            if @comment.save

                notify commentable, action: :commented,
                       text: truncate_html( m( @comment.text ) )

                format.js { redirect_to polymorphic_path( [@commentable.family, Comment].flatten, format: :js ) }

                format.html { redirect_back fallback_location: root_path, notice: 'Comment was successfully created.' }
                format.json { render json: @comment, status: :created, location: @comment }
            else
                format.js { render partial: 'form.js' }
                format.html { render action: "new" }
                format.json { render json: @comment.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /scan/comments/1
    # PUT /scan/comments/1.json
    def update
        @comment = commentable.comments.find( params.require( :id ) )

        respond_to do |format|
            if @comment.update_attributes( params.require( :comment ).permit( :text ) )
                format.html { redirect_back fallback_location: root_path, notice: 'Comment was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @comment.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /scan/comments/1
    # DELETE /scan/comments/1.json
    def destroy
        @comment = commentable.comments.find( params.require( :id ) )
        @comment.destroy

        respond_to do |format|
            format.html { redirect_to comments_url }
            format.json { head :no_content }
        end
    end

    private

    def new_comment
        @comment = commentable.comments.new( strong_params )
    end

    def strong_params
        params.require( :comment ).permit( :user_id, :text )
    end

    def commentable
        if id = params[:issue_id]
            return Issue.find( id )
        end

        if id = params[:scan_id]
            return Scan.find( id )
        end

        nil
    end
end
