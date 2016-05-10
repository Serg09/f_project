DATE = Transform /^(\d{1,2})\/(\d{1,2})\/(\d{4})$/ do |month, day, year|
  Date.new(year.to_i, month.to_i, day.to_i)
end

DOLLAR_AMOUNT = Transform /^\$\d+(?:\.\d{2})?$/ do |string_amount|
  BigDecimal.new(string_amount)
end
