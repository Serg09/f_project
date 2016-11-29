FactoryGirl.define do
  factory :carrier do
    name { Faker::Company.name }
  end
end
