@wip
Feature: Edit an order
  As an administrator
  In order to correct a mistake in an order
  I need to be able to edit it

  Scenario: An administrator edits an order
    Given there are the following orders
      | Order date | Client          | Customer name   |
      | 2016-03-02 | ACME Publishing | Sally Readerton |

    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Orders" within the page title
    And I should see the following order table
      | Order date | Client          | Customer name   |
      |   3/2/2016 | ACME Publishing | Sally Readerton |

    When I click the edit button within the 1st order row
    Then I should see "Edit order" within the page title

    When I fill in "Customer name" with "Billy Bookworm"
    And I click "Save"
    Then I should see "The order was updated successfully." within the notification area
    And I should see "Orders" within the page title
    And I should see the following order table
    And I should see the following order table
      | Order date | Client          | Customer name   |
      |   3/2/2016 | ACME Publishing | Billy Bookworm  |
