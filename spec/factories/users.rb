FactoryGirl.define do
  factory :user do
    email 'john@doe.com'
    password 'please01'
    password_confirmation { password }
  end
end
