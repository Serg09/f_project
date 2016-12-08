FactoryGirl.define do
  factory :product do
    sku { Faker::Number.hexadecimal(10) }
    description { Faker::Beer.name }
    price { Faker::Number.decimal(2, 2) }
    weight { Faker::Number.decimal(2, 2) }
  end
end
