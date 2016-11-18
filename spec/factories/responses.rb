FactoryGirl.define do
  factory :response, aliases: [:approval_response] do
    payment
    status 'approved'
    content { File.read(Rails.root.join('spec', 'fixtures', 'files', 'payment_response.yml')) }

    factory :denied_response do
      status 'denied'
      content { Faker::ChuckNorrris.fact }
    end
  end
end
