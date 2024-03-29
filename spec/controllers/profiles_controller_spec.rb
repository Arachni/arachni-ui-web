require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe ProfilesController do

    def valid_attributes
        FactoryBot.attributes_for( :profile ).merge( name: 'New name' )
    end

    before( :each ) do
        @profile = FactoryBot.create( :profile )
        signed_in_as_a_valid_user
    end

    describe "GET index" do
        it "assigns all profiles as @profiles" do
            get :index
            assigns( :profiles ).should eq( [@profile] )
        end
    end

    describe "GET show" do
        it "assigns the requested profile as @profile" do
            get :show, { id: @profile.to_param }
            assigns( :profile ).should eq( @profile )
        end
    end

    describe "GET new" do
        it "assigns a new profile as @profile" do
            get :new, { name: 'stuff', description: "test" }
            assigns( :profile ).should be_a_new( Profile )
        end
        context 'when a profile ID has been provided' do
            it 'should use that profile as a template for the new profile' do
                get :new, { id: @profile.to_param }
                assigns( :profile ).attributes.should eq( @profile.dup.attributes )
            end
        end
    end

    describe "GET edit" do
        it "assigns the requested profile as @profile" do
            get :edit, { id: @profile.to_param }
            assigns( :profile ).should eq( @profile )
        end
    end

    describe "POST create" do
        describe "with valid params" do
            it "creates a new Profile" do
                expect {
                    post :create, { profile: valid_attributes }
                }.to change(Profile, :count).by( 1 )
            end

            it "assigns a newly created profile as @profile" do
                post :create, { profile: valid_attributes }
                assigns(:profile).should be_a( Profile )
                assigns(:profile).should be_persisted
            end

            it "redirects to the created profile" do
                post :create, { profile: valid_attributes }
                response.should redirect_to(Profile.last)
            end
        end

        describe "with invalid params" do
            it "assigns a newly created but unsaved profile as @profile" do
                # Trigger the behavior that occurs when invalid params are submitted
                Profile.any_instance.stub( :save ).and_return( false )
                post :create, { profile: { } }
                assigns(:profile).should be_a_new( Profile )
            end

            it "re-renders the 'new' template" do
                # Trigger the behavior that occurs when invalid params are submitted
                Profile.any_instance.stub( :save ).and_return( false )
                post :create, { profile: { } }
                response.should render_template( "new" )
            end
        end
    end

    describe "PUT update" do
        describe "with valid params" do
            it "updates the requested profile" do
                profile = Profile.create! valid_attributes
                # Assuming there are no other profiles in the database, this
                # specifies that the Profile created on the previous line
                # receives the :update_attributes message with whatever params are
                # submitted in the request.
                Profile.any_instance.should_receive( :update_attributes ).
                    with( { 'these' => 'params', 'plugins' => {} } )

                put :update, { id: profile.to_param,
                               profile: { 'these' => 'params', 'plugins' => {} } }
            end

            it "assigns the requested profile as @profile" do
                put :update, { id: @profile.to_param, profile: valid_attributes }
                assigns( :profile ).should eq( @profile )
            end

            it "redirects to the profile" do
                put :update, { id: @profile.to_param, profile: valid_attributes }
                response.should redirect_to( @profile )
            end
        end

        describe "with invalid params" do
            it "assigns the profile as @profile" do
                # Trigger the behavior that occurs when invalid params are submitted
                Profile.any_instance.stub( :save ).and_return( false )
                put :update, { id: @profile.to_param, profile: { } }
                assigns( :profile ).should eq( @profile )
            end

            it "re-renders the 'edit' template" do
                # Trigger the behavior that occurs when invalid params are submitted
                Profile.any_instance.stub( :save ).and_return( false )
                put :update, { id: @profile.to_param, profile: { } }
                response.should render_template( "edit" )
            end
        end
    end

    describe 'PUT make_default' do
        it 'should set the requested profile as the default one' do
            @profile.default?.should be_false
            put :make_default, { id: @profile.to_param }
            get :show, { id: @profile.to_param }

            assigns( :profile ).default?.should be_true
        end
    end

    describe "DELETE destroy" do
        context 'when the profile is' do
            context 'not the default one' do
                it "destroys the requested profile" do
                    expect {
                        delete :destroy, { id: @profile.to_param }
                    }.to change( Profile, :count ).by( -1 )
                end

                it "redirects to the profiles list" do
                    delete :destroy, { id: @profile.to_param }
                    response.should redirect_to( profiles_url )
                end
            end
            context 'the default one' do
                it 'should not be allowed to be destroyed' do
                    ex = nil
                    begin
                        delete :destroy, {
                            id: FactoryBot.create( :default_profile ).to_param
                        }
                    rescue => e
                        ex = e
                    end
                    e.to_s.should == 'Cannot delete default profile.'
                end
            end
        end
    end

end
