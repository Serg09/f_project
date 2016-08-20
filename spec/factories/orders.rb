FactoryGirl.define do
  factory :order, aliases: [:incipient_order] do
    transient do
      item_count 0
    end
    association :shipping_address, factory: :address
    client
    client_order_id { Faker::Number.hexadecimal(12) }
    order_date { Faker::Date.backward(5) }
    customer_name { Faker::Name.name }
    telephone { Faker::PhoneNumber.phone_number }

    after(:create) do |order, evaluator|
      (1..(evaluator.item_count)).each do |i|
        order.items << FactoryGirl.create(:order_item, order: order)
      end
    end

    Order::STATUSES.reject{|s| s == :incipient}.each do |status|
      factory "#{status}_order".to_sym do
        status status
      end
    end
  end
end
