FactoryGirl.define do
  factory :book do
    isbn { Faker::Code.isbn }
    title { Faker::Book.title }
    format 'paperback'
  end
end
