Given /^there is a user with email address "([^"]+)" and password "([^"]+)"$/ do |email, password|
  FactoryGirl.create(:user, email: email, password: password)
end
