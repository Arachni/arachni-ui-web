require "spec_helper"

describe Scan::CommentsController do
  describe "routing" do

    it "routes to #index" do
      get("/scan/comments").should route_to("scan/comments#index")
    end

    it "routes to #new" do
      get("/scan/comments/new").should route_to("scan/comments#new")
    end

    it "routes to #show" do
      get("/scan/comments/1").should route_to("scan/comments#show", :id => "1")
    end

    it "routes to #edit" do
      get("/scan/comments/1/edit").should route_to("scan/comments#edit", :id => "1")
    end

    it "routes to #create" do
      post("/scan/comments").should route_to("scan/comments#create")
    end

    it "routes to #update" do
      put("/scan/comments/1").should route_to("scan/comments#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/scan/comments/1").should route_to("scan/comments#destroy", :id => "1")
    end

  end
end
