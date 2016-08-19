Given /^there is a client named "([^"]+)"$/ do |name|
  FactoryGirl.create(:client, name: name)
end
