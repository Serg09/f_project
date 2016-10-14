FactoryGirl.define do
  factory :response do
    payment
    status 'approved'
    content { Faker::ChuckNorris.fact }
  end
end
