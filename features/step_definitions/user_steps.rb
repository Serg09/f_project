Given /^there is a user with email (?:address )?"([^"]+)" and password "([^"]+)"$/ do |email, password|
  FactoryGirl.create(:user, email: email, password: password)
end

Given /^I am signed in as "([^\/]+)\/([^"]+)"$/ do |email, password|
  visit new_user_session_path
  within('#main-content') do
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_on 'Sign in'
  end
  within('#menu') do
    expect(page).to have_content 'Sign out'
  end
end
