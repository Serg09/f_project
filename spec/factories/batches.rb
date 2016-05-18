FactoryGirl.define do
  factory :batch, aliases: [:new_batch] do
    transient do
      orders = []
    end
    status 'new'
    after(:create) do |batch, evaluator|
      evaluator.orders.each{|o| batch.orders << o}
    end

    factory :delivered_batch do
      status 'delivered'
    end
  end
end
