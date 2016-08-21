Feature: Edit a client
  As an administrator
  In order to keep a client record up-to -ate
  I need to able to update a record for the client in the system

  Scenario: A user adds a client
    Given there are the following clients
      | Name            | Abbreviation |
      | AСME Publishing | AP           |

    And there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Clients" within the menu

    When I click "Clients" within the menu
    Then I should see "Clients" within the page title
    And I should see the following client table
      | Name            | Abbr. |
      | AСME Publishing | AP    |

    When I click the edit button within the 1st client row
    Then I should see "Edit client" within the page title

    When I fill in "Name" with "AСME Associates"
    And I fill in "Abbreviation" with "AA"
    And I click "Save"

    Then I should see "The client was updated successfully." within the notification area
    And I should see "Clients" within the page title
    And I should see the following client table
      | Name            | Abbr. |
      | AСME Associates | AA    |
