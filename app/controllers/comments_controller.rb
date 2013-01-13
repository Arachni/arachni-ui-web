class CommentsController < ApplicationController
    include ApplicationHelper

    before_filter :authenticate_user!

    load_and_authorize_resource :scan
    load_and_authorize_resource :comment, through: [:scan]

    ## GET /scan/comments
    ## GET /scan/comments.json
    def index
        @comments = commentable.comments

        html_block = if render_partial?
            proc { render partial: 'comment_list',
                         locals: { comments: commentable.comments } }
        end

        respond_to do |format|
            format.html( &html_block )
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
        @comment      = commentable.comments.new( params[:comment] )
        @comment.user = current_user

        respond_to do |format|
            if @comment.save
                format.html { redirect_to :back, notice: 'Comment was successfully created.' }
                format.json { render json: @comment, status: :created, location: @comment }
            else
                format.html { render action: "new" }
                format.json { render json: @comment.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /scan/comments/1
    # PUT /scan/comments/1.json
    def update
        @comment = commentable.comments.find( params[:id] )

        respond_to do |format|
            if @comment.update_attributes(params[:comment])
                format.html { redirect_to :back, notice: 'Comment was successfully updated.' }
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
        @comment = commentable.comments.find( params[:id] )
        @comment.destroy

        respond_to do |format|
            format.html { redirect_to comments_url }
            format.json { head :no_content }
        end
    end

    private

    def commentable
        params.each do |name, value|
            return $1.classify.constantize.find( value ) if name =~ /(.+)_id$/
        end
        nil
    end
end
