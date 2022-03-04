FactoryBot.define do
    factory :notification do
        text { Faker::Lorem.paragraph }
        association :user,  factory: :user
        association :actor, factory: :user
    end

    factory :notification_read, parent: :notification do
        read true
    end
end
