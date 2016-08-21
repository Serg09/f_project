Feature: Add a client
  As an administrator
  In order to work with a client
  I need to able to add a record for the client in the system

  Scenario: A user adds a client
    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Clients" within the menu

    When I click "Clients" within the menu
    Then I should see "Clients" within the page title

    When I click "Add" within the main content
    Then I should see "New client" within the page title

    When I fill in "Name" with "ACME Publishing"
    And I fill in "Abbreviation" with "AP"
    And I click "Save"
    Then I should see "The client was created successfully" within the notification area
    And I should see the following client table
      | Name            | Abbr. |
      | ACME Publishing | AP    |
