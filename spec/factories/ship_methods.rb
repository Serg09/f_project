FactoryGirl.define do
  factory :ship_method do
    carrier
    description { Faker::Company.buzzword }
    abbreviation { Faker::Hacker.abbreviation }
    calculator_class 'TestShipMethodCalculator'
  end
end
