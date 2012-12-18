require "spec_helper"

describe ScansController do
  describe "routing" do

    it "routes to #index" do
      get("/scans").should route_to("scans#index")
    end

    it "routes to #new" do
      get("/scans/new").should route_to("scans#new")
    end

    it "routes to #show" do
      get("/scans/1").should route_to("scans#show", :id => "1")
    end

    it "routes to #edit" do
      get("/scans/1/edit").should route_to("scans#edit", :id => "1")
    end

    it "routes to #create" do
      post("/scans").should route_to("scans#create")
    end

    it "routes to #update" do
      put("/scans/1").should route_to("scans#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/scans/1").should route_to("scans#destroy", :id => "1")
    end

  end
end
