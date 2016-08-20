Given /^there are the following products$/ do |table|
  table_as_maps(table).each do |attributes|
    FactoryGirl.create :product, attributes
  end
end
