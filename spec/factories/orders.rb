FactoryGirl.define do
  factory :order, aliases: [:incipient_order] do
    association :shipping_address, factory: :address
    client
    client_order_id { Faker::Number.hexadecimal(12) }
    order_date { Faker::Date.backward(5) }
    customer_name { Faker::Name.name }
    customer_email { Faker::Internet.email }
    telephone { Faker::PhoneNumber.phone_number }
    ship_method

    Order::STATUSES.reject{|s| s == :incipient}.each do |status|
      factory "#{status}_order".to_sym do
        after(:create) do |order|
          order << FactoryGirl.create(:product)
          order.status = status
          order.confirmation ||= SecureRandom.hex(16)
          order.save!
        end
      end
    end
  end
end
