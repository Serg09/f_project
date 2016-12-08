Freight::UspsCalculator.configure do |config|
  config.origination_postal_code = '75225' #TODO this varies based on LSI facility
  config.username = ENV['USPS_USERNAME'] || 'unknown' # TODO raise error in production
end
