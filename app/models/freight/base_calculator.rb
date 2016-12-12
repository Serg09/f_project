module Freight
  class BaseCalculator
    attr_accessor :order

    def rate
      @rate ||= calculate_rate
    end

    protected

    def calculate_rate
      raise 'BaseCalculator#rate must be overriden in a derived class'
    end

    def total_weight
      @total_weight ||= order.items.reduce(0) do |sum, item|
        product = Product.find_by_sku(item.sku)
        sum + (product.weight * item.quantity)
      end
    end
  end
end
