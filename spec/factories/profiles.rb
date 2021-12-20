FactoryBot.define do
    factory :profile do
        name        { Faker::Lorem.sentence }
        description { Faker::Lorem.paragraph }
        association :owner, factory: :user
    end

    factory :profile_default, parent: :profile do
        default true
    end

    factory :profile_global, parent: :profile do
        global true
    end
end
