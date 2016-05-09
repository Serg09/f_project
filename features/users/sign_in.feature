Feature: Sign in
  As a user,
  In order to access the site, 
  I need to be able to sign in

  Scenario: A user signs into the site
    Given there is a user with email address "john@doe.com" and password "please01"

    When I am on the home page
    Then I should see "Sign in" within the navigation

    When I click "Sign in" within the navigation
    Then I should see "Sign in" within the page title

    When I fill in "Email" with "john@doe.com"
    And I fill in "Password" with "please01"
    And I click "Sign in" within the main content
    Then I should see "Signed in successfully" within the notification area
    And I should see "Sign out" within the navigation
