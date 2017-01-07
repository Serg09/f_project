FactoryGirl.define do
  factory :product, aliases: [:physical_product] do
    sku { Faker::Number.hexadecimal(10) }
    description { Faker::Beer.name }
    price { Faker::Number.decimal(2, 2) }
    weight { Faker::Number.decimal(2, 2) }
    fulfillment_type 'physical'

    factory :electronic_product do
      fulfillment_type 'electronic'
    end
  end
end
