FactoryGirl.define do
    factory :profile do
        name        'Test Profile'
        description 'Test profile description...'
    end

    factory :default_profile, class: Profile do
        name        'Default Profile'
        description 'Default profile description...'
        default      true
    end
end
