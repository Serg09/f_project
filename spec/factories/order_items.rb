FactoryGirl.define do
  factory :order_item do
    order
    sku { Faker::Code.isbn }
    description { Faker::Book.title }
    quantity { Faker::Number.between(1, 5) }
    unit_price { Faker::Number.decimal(2) }
    discount_percentage 0.00
    tax { Faker::Number.decimal(2) }

    factory :processing_order_item do
      status 'processing'
    end
  end
end
