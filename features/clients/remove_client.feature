Feature: Remove a client
  As an administrator
  In order to correct a mistake
  I need to be able to remove a client record

  Scenario: A user adds a client
    Given there are the following clients
      | Name            | Abbreviation |
      | AСME Publishing | AP           |
      | Other Publisher | OP           |

    And there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Clients" within the menu

    When I click "Clients" within the menu
    Then I should see "Clients" within the page title
    And I should see the following client table
      | Name            | Abbr. |
      | AСME Publishing | AP    |
      | Other Publisher | OP    |

    When I click the delete button within the 1st client row
    Then I should see "The client was removed successfully" within the notification area
    And I should see "Clients" within the page title
    And I should see the following client table
      | Name            | Abbr. |
      | Other Publisher | OP    |
