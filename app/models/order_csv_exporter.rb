class OrderCsvExporter
  # SKU
  # Title
  # Quantity
  # OrderID (max 15)
  # line_item_no (max 5)
  # Customer Alternate Reference
  # Shipping Method
  # Recipient (45 max)
  # address 1 (45 max)
  # address 2 (45 max)
  # city (30 max)
  # state
  # postal_code
  # country_code (3 characters)
  # telephone
  # promo code
  # address 1 (special address, optional)
  # address 2
  # city
  # state
  # postal_code
  # country_code
  # telephone
  def initialize(orders)
    @orders = orders
  end

  def content
    csv = CSV.generate do |csv|
      @orders.each do |order|
        order.items.physical.each do |item|
          csv << [
            item.sku,
            item.description,
            item.quantity,
            "%06d" % order.id,
            item.line_item_no,
            nil,
            order.ship_method.abbreviation,
            order.shipping_address.recipient.slice(0,45),
            order.shipping_address.line_1.slice(0, 45),
            order.shipping_address.line_2.try(:slice, 0, 45),
            order.shipping_address.city.slice(0, 30),
            order.shipping_address.state,
            order.shipping_address.postal_code,
            order.shipping_address.country_code,
            order.telephone
          ]
        end
      end
    end
  end
end
