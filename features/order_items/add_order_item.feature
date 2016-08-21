@wip
Feature: Add an order item
  As an administrator
  In order to allow the purchase of a product
  I need to be able to add a line item to an order

  Scenario: A user adds an item to an order
    Given there are the following products
      | SKU    | Description   | Price |
      | 123456 | Deluxe Widget | 19.99 |

    And there is a client named "ACME Publishing"
    And client "ACME Publishing" has an order on 3/2/2016

    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Orders" within the page title
    And I should see the following order table
      | Order date | Client          |
      |   3/2/2016 | ACME Publishing |

    When I click the edit button within the 1st order row
    Then I should see "Edit order" within the page title
    And I click "Add" within the main content
    Then I should see "New order item" within the page title

    When I fill in "SKU" with "123456"
    And I fill in "Quantity" with "2"
    And I click "Save"
    Then I should see "The order item was created successfully." within the notification area
    And I should see "Edit order" within the page title
    And I should see the following order item table
      | SKU    | Description   | Unit price | Qty | Ext. Price | Total Price |
      | 123456 | Deluxe Widget |      19.99 |   2 |      39.98 |       39.98 |
