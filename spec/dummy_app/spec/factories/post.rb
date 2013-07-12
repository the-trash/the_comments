FactoryGirl.define do
  factory :post, class: Post do
    sequence(:title)   { Faker::Lorem.sentence }
    sequence(:content) { Faker::Lorem.sentence }
  end
end