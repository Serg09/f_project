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
      @total_weight ||= order.items.physical.
        map{|i| {item: i, product: Product.find_by_sku(i.sku)}}.
        select{|tuple| tuple[:product].present?}.
        reduce(0) do |sum, tuple|
          sum + tuple[:product].weight * tuple[:item].quantity
        end
    end
  end
end
