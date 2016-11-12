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

When /^I click the (.*) button$/ do |button_description|
  selector = ".#{description_to_id(button_description)}-button"
  button = page.find(selector)
  button.click
end

When /^I select "([^"]+)" from the "([^"]+)" list$/ do |value, locator|
  select value, from: locator
end

Then /^I should see the following (.*) table$/ do |description, expected_table|
  id = "##{description_to_id(description)}-table"
  html_table = find(id)
  actual_table = parse_table(html_table)
  expected_table.diff! actual_table
end

Given /^today is (#{DATE})$/ do |date|
  Timecop.freeze(date)
end
