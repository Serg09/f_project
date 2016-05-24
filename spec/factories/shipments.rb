FactoryGirl.define do
  factory :shipment do
    association :order, factory: :order, item_count: 1
    external_id { Faker::Number.hexadecimal(10) }
    ship_date { Faker::Date.between(2.days.ago, 2.days.from_now) }
    quantity 1
    weight { Faker::Number.decimal(2, 2) }
    freight_charge { Faker::Number.decimal(2, 2) }
    handling_charge { Faker::Number.decimal(2, 2) }
    collect_freight false
  end
end
