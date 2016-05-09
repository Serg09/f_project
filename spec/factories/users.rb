FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    password 'please01'
    password_confirmation { password }
  end
end
