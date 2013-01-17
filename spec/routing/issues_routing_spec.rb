require "spec_helper"

describe IssuesController do
  describe "routing" do

    it "routes to #index" do
      get("/issues").should route_to("issues#index")
    end

    it "routes to #new" do
      get("/issues/new").should route_to("issues#new")
    end

    it "routes to #show" do
      get("/issues/1").should route_to("issues#show", :id => "1")
    end

    it "routes to #edit" do
      get("/issues/1/edit").should route_to("issues#edit", :id => "1")
    end

    it "routes to #create" do
      post("/issues").should route_to("issues#create")
    end

    it "routes to #update" do
      put("/issues/1").should route_to("issues#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/issues/1").should route_to("issues#destroy", :id => "1")
    end

  end
end
