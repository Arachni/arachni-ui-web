require "spec_helper"

describe DispatchersController do
  describe "routing" do

    it "routes to #index" do
      get("/dispatchers").should route_to("dispatchers#index")
    end

    it "routes to #new" do
      get("/dispatchers/new").should route_to("dispatchers#new")
    end

    it "routes to #show" do
      get("/dispatchers/1").should route_to("dispatchers#show", :id => "1")
    end

    it "routes to #edit" do
      get("/dispatchers/1/edit").should route_to("dispatchers#edit", :id => "1")
    end

    it "routes to #create" do
      post("/dispatchers").should route_to("dispatchers#create")
    end

    it "routes to #update" do
      put("/dispatchers/1").should route_to("dispatchers#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/dispatchers/1").should route_to("dispatchers#destroy", :id => "1")
    end

  end
end
