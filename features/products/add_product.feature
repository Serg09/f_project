Feature: Add product
  As an administrator
  In order to make something available for purchase
  I need to be able to add a product to the catalog

  Scenario: A user adds a product
    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Products" within the menu

    When I click "Products" within the menu
    Then I should see "Products" within the page title

    When I click "Add" within the main content
    Then I should see "New product" within the page title

    When I fill in "SKU" with "123456"
    And I fill in "Description" with "Deluxe Widget"
    And I fill in "Price" with "19.99"
    And I click "Save"
    Then I should see "Products" within the page title
    And I should see the following product table
      | SKU    | Description   | Price |
      | 123456 | Deluxe Widget | 19.99 |
