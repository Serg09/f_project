FactoryGirl.define do
  factory :package do
    shipment_item
    package_id { Faker::Number.hexadecimal(10) }
    tracking_number { Faker::Number.hexadecimal(12) }
    quantity { Faker::Number.between(1, 10) }
    weight { Faker::Number.decimal(2, 2) }
  end
end
