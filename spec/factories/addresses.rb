FactoryGirl.define do
  factory :address do
    line_1 { Faker::Address.street_address }
    line_2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state }
    postal_code { Faker::Address.postcode }
    country_code 'US'
    recipient { Faker::Name.name }
  end
end
