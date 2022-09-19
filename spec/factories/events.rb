FactoryBot.define do
  factory :event do
    title { "#{Faker::Relationship.familial} #{Faker::Verb.past} #{Faker::Cannabis.medical_use}"}
    start_date { '2022-07-20 12:30:00' }
    unit { "days" }
    user { create :user }
  end
end
