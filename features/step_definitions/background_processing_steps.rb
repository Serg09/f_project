Then /^order for (#{CLIENT}) on (#{DATE}) should be queued for export$/ do |client, order_date|
  order = client.orders.find_by(order_date: order_date)
  expect(ExportProcessor).to \
    receive(:perform).
    with(hash_including(order_id: order.id))
end
