# Class shells to mock for tests
module Braintree
  class ClientToken
    def self.generate; end
  end

  class Transaction
    def self.sale(options); end
  end
end
