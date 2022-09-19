FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    lang { %w[en zh-hk].sample }
    time_unit {  %w[minutes hours days weeks months years].sample }
    registered_user { true }
  end
end
