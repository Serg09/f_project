Freight::UpsCalculator.configure do |config|
  config.username = ENV['UPS_USERNAME']
  config.password = ENV['UPS_PASSWORD']
  config.access_key = ENV['UPS_ACCESS_KEY']

  ADDRESS = Struct.new :postal_code, :country_code
  config.company_address = ADDRESS.new '97005',
                                       'US'
  origination_company_address = ADDRESS.new '37086',
                                            'US'
  config.origination_company = OpenStruct.new address: origination_company_address

  config.rate_service_url = Rails.env.production? ?
    'https://onlinetools.ups.com/rest/Rate' :
    'https://wwwcie.ups.com/rest/Rate'
end
