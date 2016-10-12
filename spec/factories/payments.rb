FactoryGirl.define do
  factory :payment, aliases: [:pending_payment] do
    amount { Faker::Number.decimal(2, 2) }
    state 'pending'
    external_id  { Faker::Number.hexadecimal(10) }
    external_fee { amount * 0.03 }

    factory :approved_payment do
      state 'approved'
    end

    factory :completed_payment do
      state 'completed'
    end

    factory :failed_payment do
      state 'failed'
    end

    factory :refunded_payment do
      state 'refunded'
    end
  end
end
