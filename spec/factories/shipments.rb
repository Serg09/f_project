FactoryGirl.define do
  factory :shipment do
    order
    external_id { Faker::Number.hexadecimal(10) }
    ship_date { Faker::Date.between(2.days.ago, 2.days.from_now) }
    quantity 1
    weight { Faker::Number.decimal }
    freight_charge { Faker::Number.decimal }
    handling_charge { Faker::Number.decimal }
    collect_freight false
    freight_responsibility 
    cancel_code
    cancel_reason
  end
end
