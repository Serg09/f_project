Feature: Add product
  As an administrator
  In order to make something available for purchase
  I need to be able to add a product to the catalog

  Background:
    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Products" within the menu

    When I click "Products" within the menu
    Then I should see "Products" within the page title

    When I click "Add" within the main content
    Then I should see "New product" within the page title

  Scenario: A user adds a product with physical fulfillment
    When I fill in "SKU" with "123456"
    And I fill in "Description" with "Deluxe Widget"
    And I fill in "Price" with "19.99"
    And I select "Physical" from the "Fulfillment type" list
    And I fill in "Weight" with "1.5"
    And I click "Save"
    Then I should see "Products" within the page title
    And I should see the following product table
      | SKU    | Description   | Price |
      | 123456 | Deluxe Widget | 19.99 |

  Scenario: A user adds a product with electronic fulfillment
    When I fill in "SKU" with "123456"
    And I fill in "Description" with "Deluxe Digital Widget"
    And I fill in "Price" with "19.99"
    And I select "Electronic" from the "Fulfillment type" list
    And I click "Save"
    Then I should see "Products" within the page title
    And I should see the following product table
      | SKU    | Description           | Price |
      | 123456 | Deluxe Digital Widget | 19.99 |
