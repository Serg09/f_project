FactoryGirl.define do
  factory :payment, aliases: [:pending_payment] do
    order
    amount { Faker::Number.decimal(2, 2) }
    state 'pending'

    factory :approved_payment do
      state 'approved'
      external_id  { Faker::Number.hexadecimal(10) }
      external_fee { amount * 0.03 }
    end

    factory :completed_payment do
      state 'completed'
      external_id  { Faker::Number.hexadecimal(10) }
      external_fee { amount * 0.03 }
    end

    factory :failed_payment do
      state 'failed'
      external_id  { Faker::Number.hexadecimal(10) }
      external_fee { amount * 0.03 }
    end

    factory :refunded_payment do
      state 'refunded'
      external_id  { Faker::Number.hexadecimal(10) }
      external_fee { amount * 0.03 }
    end
  end
end
