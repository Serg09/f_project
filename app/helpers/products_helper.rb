module ProductsHelper
  def fulfillment_type_options
    options_for_select Product::FULFILLMENT_TYPES.map do |type|
      [type.capitalize, type]
    end
  end
end
