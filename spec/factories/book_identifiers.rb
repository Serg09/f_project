FactoryGirl.define do
  factory :book_identifier do
    client
    book
    code { Faker::Lorem.characters(5) }
  end
end
