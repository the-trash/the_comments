FactoryGirl.define do
  factory :user, class: User do
    sequence(:username) { Faker::Name.name }
    sequence(:email)    { Faker::Internet.email }
  end
end