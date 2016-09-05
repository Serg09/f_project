DATE = Transform /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/ do |month, day, year|
  Date.new(year.to_i, month.to_i, day.to_i)
end

DOLLAR_AMOUNT = Transform /^\$(\d+(?:\.\d{2}))?$/ do |string_amount|
  BigDecimal.new(string_amount)
end

CLIENT = Transform /^client "([^"]+)"$/ do |name|
  Client.find_by(name: name) || FactoryGirl.create(:client, name: name)
end

ORDER = Transform /^order for client "([^"]+)" on (\d{1,2})\/(\d{1,2})\/(\d{4})$/ do |client_name, month, day, year|
  order_date = Date.new(year.to_i, month.to_i, day.to_i)
  client = Client.find_by(name: client_name) || FactoryGirl.create(:client, name: client_name)
  client.orders.find_by(order_date: order_date)
end
