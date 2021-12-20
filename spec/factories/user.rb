FactoryBot.define do

    factory :user do |d|
        name { Faker::Name.name }
        email { Faker::Internet.email }
        password { 'pass123456' }
        password_confirmation { 'pass123456' }
    end

end
