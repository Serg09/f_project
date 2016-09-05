Given /^"([^"]+)" ordered "([^"]+)" - "([^"]+)" for (#{DOLLAR_AMOUNT}) on (#{DATE})$/ do |customer_name, sku, description, price, date|
  order = FactoryGirl.create(:order, customer_name: customer_name,
                                     order_date: date)
  item = FactoryGirl.create(:order_item, order: order,
                                         sku: sku,
                                         quantity: 1,
                                         description: description,
                                         unit_price: price,
                                         tax: price * 0.0825,
                                         freight_charge: 0)
end

Given /^there are the following orders$/ do |table|
  table_as_maps(table) do |attributes|
    client = Client.find_by name: attributes[:client]
    client ||= FactoryGirl.create :client, name: attributes[:client]
    FactoryGirl.create :order, attributes.merge(client: client)
  end
end

Given /^(#{CLIENT}) has an order on (#{DATE})$/ do |client, order_date|
  FactoryGirl.create :incipient_order, client: client,
                                       order_date: order_date
end

Given /^(#{CLIENT}) submitted an order on (#{DATE})$/ do |client, order_date|
  FactoryGirl.create :submitted_order, client: client,
                                       order_date: order_date
end

Then /^(#{ORDER}) should be marked as (.*)$/ do |order, status|
  expect(order.status).to eq status
end
