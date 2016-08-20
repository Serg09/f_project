Feature: Remove an order
  As an administrator
  In order to correct a mistake in an order
  I need to be able to remove it

  Scenario: An administrator removes an order
    Given there are the following orders
      | Order date | Client          | Customer name   |
      | 2016-03-02 | ACME Publishing | Sally Readerton |
      | 2016-02-27 | ACME Publishing | Billy Bookworm  |

    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Orders" within the page title
    And I should see the following order table
      | Order date | Client          | Customer name   |
      |   3/2/2016 | ACME Publishing | Sally Readerton |
      |  2/27/2016 | ACME Publishing | Billy Bookworm  |

    When I click the delete button within the 1st order row
    Then I should see "The order was removed successfully." within the notification area
    And I should see the following order table
      | Order date | Client          | Customer name   |
      |  2/27/2016 | ACME Publishing | Billy Bookworm  |
