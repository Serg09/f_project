Feature: Add an order
  As an administrator
  In order to have product delivered to a customer
  I need to be able to enter an order into the system

  Scenario: An administrator adds an order
    Given there is a client named "ACME Book Co"
    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Orders" within the page title

    When I click "Add" within the main content
    Then I should see "New order" within the page title

    When I fill in "Order date" with "3/2/2016"
    And I select "ACME Book Co" from the "Client" list
    And I fill in "Client order ID" with "987654"
    And I fill in "Customer name" with "Sally Readerton"
    And I fill in "Telephone" with "214-555-1234"
    And I fill in "Line 1" with "1234 Main St"
    And I fill in "Line 2" with "Apt 227"
    And I fill in "City" with "Dallas"
    And I fill in "State" with "TX"
    And I fill in "Postal code" with "75200"
    And I fill in "Country code" with "US"
    And I click "Save"
    Then I should see "The order was created successfully." within the notification area
    And I should see the following order table
      | Order date | Customer name   | Total |
      |   3/2/2016 | Sally Readerton | $0.00 |
