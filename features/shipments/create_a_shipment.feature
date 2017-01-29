@wip
Feature: Create a shipment
  As an administrator
  In order to update an order with shipping information
  I need to be able to create a shipment record

  Scenario: An user creates a shipment
    Given there are the following products
      | SKU    | Description   |
      | 123456 | Deluxe Widget |

    And there is a client named "ACME Publishing"
    And client "ACME Publishing" submitted an order on 3/2/2016
    And order for client "ACME Publishing" on 3/2/2016 has the following items
      | SKU    | Quantity |
      | 123456 |        2 |
    And order for client "ACME Publishing" on 3/2/2016 is being processed

    And there is a user with email "john@doe.com" and password "please01"

    When I am signed in as "john@doe.com/please01"
    And I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Orders" within the page title
    And I should see "Processing" within the secondary menu

    When I click "Processing" within the secondary menu
    Then I should see the following order table
      | Order date | Client          |
      |   3/2/2016 | ACME Publishing |

    When I click the shipments button within the 1st order row
    Then I should see "Shipments for" within the page title

    When I click "Add" within the main content
    Then I should see "New shipment for" within the page title

    When I fill in "External ID" with "54321"
    And I fill in "Ship Date" with "3/6/2016"
    And I fill in "Weight" with "1.2"
    And I fill in "Freight Charge" with "5.65"
    And I fill in "Handling Charge" with "1.65"
    And I click "Save"
    Then I should see "The shipment was created successfully" within the notification area
    And I should see "Shipment items" within the page title

    When I click "Add" within the main content
    Then I should see "New shipment item" within the page titled

    When I select "1 - 123456 - Deluxe Widget" from the "Item" list
    And I click "Save"
    Then I should see "The shipment item was created successfully" within the notification area
    And I should see "Shipment items" within the page title
    And I should see the following shipment items table
      | Line # | SKU    | Description   | Shipped Qty. |
      |      1 | 123456 | Deluxe Widget |            2 |
