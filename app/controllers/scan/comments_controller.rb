class Scan::CommentsController < ApplicationController
    ## GET /scan/comments
    ## GET /scan/comments.json
    #def index
    #    @scan_comments = Scan::Comment.all
    #
    #    respond_to do |format|
    #        format.html # index.html.erb
    #        format.json { render json: @scan_comments }
    #    end
    #end
    #
    ## GET /scan/comments/1
    ## GET /scan/comments/1.json
    #def show
    #    @scan_comment = Scan::Comment.find(params[:id])
    #
    #    respond_to do |format|
    #        format.html # show.html.erb
    #        format.json { render json: @scan_comment }
    #    end
    #end
    #
    ## GET /scan/comments/new
    ## GET /scan/comments/new.json
    #def new
    #    @scan_comment = Scan::Comment.new
    #
    #    respond_to do |format|
    #        format.html # new.html.erb
    #        format.json { render json: @scan_comment }
    #    end
    #end
    #
    ## GET /scan/comments/1/edit
    #def edit
    #    @scan_comment = Scan::Comment.find(params[:id])
    #end

    # POST /scan/comments
    # POST /scan/comments.json
    def create
        begin
            current_user.scans.find( params[:scan_comment][:scan_id] )
        rescue ActiveRecord::RecordNotFound
            fail 'You do not have permission to access this scan.'
        end

        @scan_comment      = Scan::Comment.new(params[:scan_comment])
        @scan_comment.user = current_user

        respond_to do |format|
            if @scan_comment.save
                format.html { redirect_to :back, notice: 'Comment was successfully created.' }
                format.json { render json: @scan_comment, status: :created, location: @scan_comment }
            else
                format.html { render action: "new" }
                format.json { render json: @scan_comment.errors, status: :unprocessable_entity }
            end
        end
    end

    # PUT /scan/comments/1
    # PUT /scan/comments/1.json
    def update
        begin
            current_user.scans.find( params[:scan_comment][:scan_id] )
        rescue ActiveRecord::RecordNotFound
            fail 'You do not have permission to access this scan.'
        end

        @scan_comment = Scan::Comment.find(params[:id])

        respond_to do |format|
            if @scan_comment.update_attributes(params[:scan_comment])
                format.html { redirect_to :back, notice: 'Comment was successfully updated.' }
                format.json { head :no_content }
            else
                format.html { render action: "edit" }
                format.json { render json: @scan_comment.errors, status: :unprocessable_entity }
            end
        end
    end

    # DELETE /scan/comments/1
    # DELETE /scan/comments/1.json
    def destroy
        begin
            current_user.scans.find( params[:scan_comment][:scan_id] )
        rescue ActiveRecord::RecordNotFound
            fail 'You do not have permission to access this scan.'
        end

        @scan_comment = Scan::Comment.find(params[:id])
        @scan_comment.destroy

        respond_to do |format|
            format.html { redirect_to scan_comments_url }
            format.json { head :no_content }
        end
    end
end
