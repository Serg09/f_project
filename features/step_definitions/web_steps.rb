When /^I am on the (.*) page$/ do |page_description|
  path = path_for(page_description)
  visit path
end

Then /^(.+) within the (.+)$/ do |step_content, context|
  locator = locator_for(context)
  within(locator){step(step_content)}
end

Then /^I should see "([^"]+)"$/ do |content|
  expect(page).to have_content(content)
end

When /^I fill in "([^"]+)" with "([^"]+)"$/ do |locator, content|
  fill_in locator, with: content
end

When /^I click "([^"]+)"$/ do |locator|
  click_on locator
end
