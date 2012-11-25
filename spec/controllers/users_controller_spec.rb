require 'spec_helper'

describe UsersController do

    context 'when a user is' do
        before( :each ) { signed_in_as_a_valid_user }

        context 'logged in' do
            describe "GET 'show'" do

                it "should be successful" do
                    get :show, id: @user.id
                    response.should be_success
                end

                it "should find the right user" do
                    get :show, id: @user.id
                    assigns( :user ).should == @user
                end

            end
        end

        context 'not logged in' do
            before( :each ) { sign_out }

            describe "GET 'show'" do
                it "should redirect to" do
                    get :show, id: @user.id
                    response.status.should == 302
                end
            end
        end
    end

end
