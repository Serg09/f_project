FactoryGirl.define do
  factory :order_item do
    order
    sequence :line_item_no do |n|
      n
    end
    sku { Faker::Code.isbn }
    description { Faker::Book.title }
    quantity { Faker::Number.between(1, 5) }
    price { Faker::Number.decimal(2) }
    discount_percentage 0.00
    freight_charge { Faker::Number.decimal(2) }
    tax { Faker::Number.decimal(2) }
  end
end
