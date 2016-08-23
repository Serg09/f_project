Feature: Edit an order item
  As an administrator
  In order to correct a mistake
  I need to be able to edit a line item in an order

  Scenario: A user edits an item in an order
    Given there are the following products
      | SKU    | Description   | Price |
      | 123456 | Deluxe Widget | 19.99 |

    And there is a client named "ACME Publishing"
    And client "ACME Publishing" has an order on 3/2/2016
    And order for client "ACME Publishing" on 3/2/2016 has the following items
      | SKU    | Quantity |
      | 123456 |         2|

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
    And I should see the following order item table
      | SKU    | Description   | Unit price | Qty | Ext. price | Total price |
      | 123456 | Deluxe Widget |      19.99 |   2 |      39.98 |       39.98 |

    When I click the edit button within the 1st order item row
    Then I should see "Edit order item" within the page title

    When I fill in "Quantity" with "3"
    And I click "Save"
    Then I should see "The order item was updated successfully." within the notification area
    And I should see "Edit order" within the page title
    And I should see the following order item table
      | SKU    | Description   | Unit price | Qty | Ext. price | Total price |
      | 123456 | Deluxe Widget |      19.99 |   3 |      59.97 |       59.97 |
