Feature: Remove an order item
  As an administrator
  In order to correct a mistake
  I need to be able to remove a line item from an order

  Scenario: A user removes an item in from order
    Given there are the following products
      | SKU    | Description    | Price |
      | 123456 | Deluxe Widget  | 19.99 |
      | 234567 | Premium Widget | 24.99 |

    And there is a client named "ACME Publishing"
    And client "ACME Publishing" has an order on 3/2/2016
    And order for client "ACME Publishing" on 3/2/2016 has the following items
      | SKU    | Quantity |
      | 123456 |        2 |
      | 234567 |        1 |

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
      | SKU     | Description         | Unit price | Qty | Ext. price | Total price |
      | 123456  | Deluxe Widget       |      19.99 |   2 |      39.98 |       39.98 |
      | 234567  | Premium Widget      |      24.99 |   1 |      24.99 |       24.99 |
      | FREIGHT | Shipping & Handling |       5.00 |   1 |       5.00 |        5.00 |

    When I click the delete button within the 1st order item row
    Then I should see "The order item was removed successfully." within the notification area
    And I should see the following order item table
      | SKU     | Description         | Unit price | Qty | Ext. price | Total price |
      | 234567  | Premium Widget      |      24.99 |   1 |      24.99 |       24.99 |
      | FREIGHT | Shipping & Handling |       5.00 |   1 |       5.00 |        5.00 |
