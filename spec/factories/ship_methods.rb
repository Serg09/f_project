FactoryGirl.define do
  factory :ship_method do
    carrier
    description { Faker::Company.buzzword }
    abbreviation { SecureRandom.hex(10) }
    calculator_class 'TestShipMethodCalculator'
  end
end
