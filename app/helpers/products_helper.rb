module ProductsHelper
  def fulfillment_type_options(selected = nil)
    options = Product::FULFILLMENT_TYPES.map do |type|
      [type.capitalize, type]
    end
    options_for_select options, selected
  end
end
