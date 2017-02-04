module ShipmentItemsHelper
  def order_item_options_for_shipment_item_select(shipment, shipment_item)
    options_for_select shipment.order.items.
      select(&:standard_item?).
      map{|i| ["#{i.line_item_no} - #{i.sku} - #{i.description}", i.id]}
  end
end
