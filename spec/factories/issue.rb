FactoryGirl.define do
    factory :issue do
        digest { Digest::SHA2.hexdigest rand( 9999 ).to_s }
    end
end
