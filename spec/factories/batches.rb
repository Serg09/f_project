FactoryGirl.define do
  factory :batch do
    transient do
      orders = []
    end
    after(:create) do |batch, evaluator|
      evaluator.orders.each{|o| batch.orders << o}
    end
  end
end
