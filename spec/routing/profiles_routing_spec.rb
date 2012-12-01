require "spec_helper"

describe ProfilesController do
    describe "routing" do

        it "routes to #index" do
            get( "/profiles" ).should route_to( "profiles#index" )
        end

        it "routes to #new" do
            get( "/profiles/new" ).should route_to( "profiles#new" )
        end

        it "routes to #new with id" do
            get( "/profiles/new/1" ).should route_to( "profiles#new", id: "1" )
        end

        it "routes to #show" do
            get( "/profiles/1" ).should route_to( "profiles#show", id: "1" )
        end

        it "routes to #edit" do
            get( "/profiles/1/edit" ).should route_to( "profiles#edit", id: "1" )
        end

        it "routes to #make_default with id" do
            put( "/profiles/1/make_default" ).should route_to( "profiles#make_default", id: "1" )
        end

        it "routes to #create" do
            post( "/profiles" ).should route_to( "profiles#create" )
        end

        it "routes to #update" do
            put( "/profiles/1" ).should route_to( "profiles#update", id: "1" )
        end

        it "routes to #destroy" do
            delete( "/profiles/1" ).should route_to( "profiles#destroy", id: "1" )
        end

    end
end
