require 'spec_helper'

describe HomeController do

    context 'when a user is' do
        before( :each ) { signed_in_as_a_valid_user }

        context 'logged in' do
            describe "GET 'index'" do
                it "should be successful" do
                    get 'index'
                    response.should be_success
                end
            end
        end

        context 'not logged in' do
            before( :each ) { sign_out }

            describe "GET 'index'" do
                it "should not be successful" do
                    get 'index'
                    response.status.should == 302
                end
            end
        end
    end

end
