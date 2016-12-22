Freight::UpsCalculator.configure do |config|
  ADDRESS = Struct.new :postal_code, :country_code
  config.company_address = ADDRESS.new '97005',
                                       'US'
  origination_company_address = ADDRESS.new '37086',
                                            'US'
  config.origination_company = OpenStruct.new address: origination_company_address

  config.rate_service_url = 'http://www.needtofindit.com'
end
