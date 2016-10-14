# Class shells to mock for tests
module Braintree
  class ClientToken
    def self.generate; end
  end

  class Transaction
    def self.sale(options); end
    def self.refund(id); end
    def self.void(id); end
    def self.find(id); end
  end
end
