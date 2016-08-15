FactoryGirl.define do
  factory :client do
    name { Faker::Company.name }
    abbreviation { Faker::Lorem.characters(5) }
  end
end
