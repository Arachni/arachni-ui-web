FactoryBot.define do
    factory :comment do
        text { Faker::Lorem.paragraph }
        association :commentable, factory: :issue
    end
end
