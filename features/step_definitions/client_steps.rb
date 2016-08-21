Given /^there is a client named "([^"]+)"$/ do |name|
  FactoryGirl.create(:client, name: name)
end

Given /^there are the following clients$/ do |table|
  table_as_maps(table).each do |attributes|
    FactoryGirl.create :client, attributes
  end
end
