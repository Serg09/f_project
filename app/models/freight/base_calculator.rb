module Freight
  class BaseCalculator
    attr_accessor :order

    protected

    def total_weight
      @total_weight ||= order.items.reduce(0) do |sum, item|
        product = Product.find_by_sku(item.sku)
        sum + (product.weight * item.quantity)
      end
    end
  end
end
