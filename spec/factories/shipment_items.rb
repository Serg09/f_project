FactoryGirl.define do
  factory :shipment_item do
    shipment
    order_item_id  { shipment.order.items.first.id }
    external_line_no 1
    sku { shipment.order.items.first.sku }
    unit_price { shipment.order.items.first.unit_price }
    shipped_quantity 1
  end
end
