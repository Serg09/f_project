Freight::UpsCalculator.configure do |config|
  ADDRESS = Struct.new :line_1, :line_2, :city, :state, :postal_code, :country_code
  config.company_address = ADDRESS.new '1234 Test St',
                                       'Suite 100',
                                       'Portland', 
                                       'OR',
                                       '99999',
                                       'US'
  origination_company_address = ADDRESS.new '4321 Other St',
                                            nil,
                                            'Dallas',
                                            'TX',
                                            '75225'
  config.origination_company = OpenStruct.new address: origination_company_address
end
