module UserHelper
    def valid_user
        @user ||= FactoryBot.create( :user )
    end

    def sign_out( user = nil )
        super user || valid_user
    end
end

#module for helping controller specs
module ValidUserHelper
    include UserHelper

    def signed_in_as_a_valid_user
        sign_in valid_user # method from devise:TestHelpers
    end
end

# module for helping request specs
module ValidUserRequestHelper
    include UserHelper

    # for use in request specs
    def sign_in_as_a_valid_user
        post_via_redirect user_session_path,
                          'user[email]'    => valid_user.email,
                          'user[password]' => valid_user.password
    end
end
