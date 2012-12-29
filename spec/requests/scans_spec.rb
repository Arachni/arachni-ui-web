require 'spec_helper'

describe "Scans" do
    context 'when a user is' do
        context 'not logged in' do
            describe "GET /scans" do
                it "should redirect to the login screen" do
                    get scans_path
                    response.status.should == 302

                    response.header['Location'].should == new_user_session_url
                end
            end
        end
        context 'logged in' do
            describe "GET /scans" do
                it "should succeed" do
                    sign_in_as_a_valid_user

                    get scans_path
                    response.status.should == 200
                end
            end
        end
    end
end
