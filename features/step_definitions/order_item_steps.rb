Given /^order for (#{CLIENT}) on (#{DATE}) has the following items$/ do |client, order_date, table|
  order = client.orders.find_by(order_date: order_date)
  table_as_maps(table) do |attributes|
    order.add_item attributes[:sku], attributes[:quantity] || 1
  end
end
