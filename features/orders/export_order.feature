@wip
Feature: Export an order
  As an administrator
  In order to have an order fulfilled
  I need to be able to export it to the fulfillment provider

  Scenario: A user exports an order
    Given there are the following products
      | SKU   | Description   |
      | 123456| Deluxe Widget |

    And there is a client named "ACME Publishing"
    And client "ACME Publishing" submitted an order on 3/2/2016
    And order for client "ACME Publishing" on 3/2/2016 has the following items
      | SKU    | Quantity |
      | 123456 |        2 |

    And there is a user with email "john@doe.com" and password "please01"

    When I am signed in as "john@doe.com/please01"
    And I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Submitted" within the secondary menu

    And I click "Submitted" within the secondary menu
    Then I should see the following order table
      | Order date | Client          |
      |   3/2/2016 | ACME Publishing |

    When I click the export button within the 1st order row
    Then I should see "The order has been marked for export." within the notification area
    And order for client "ACME Publishing" on 3/2/2016 should be marked as exporting
