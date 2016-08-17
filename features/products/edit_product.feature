Feature: Edit product
  As an administrator
  In order to keep a product up-to-date
  I need to be able to update a product in the catalog

  Scenario: A user edits a product
    Given there are the following products
      | SKU    | Description   | Price |
      | 123456 | Deluxe Widget | 19.99 |

    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Products" within the menu

    When I click "Products" within the menu
    Then I should see "Products" within the page title
    And I should see the following product table
      | SKU    | Description   | Price |
      | 123456 | Deluxe Widget | 19.99 |

    When I click the edit button within the 1st product row
    Then I should see "Edit product" within the page title

    When I fill in "Price" with "24.99"
    And I fill in "Description" with "Premium Widget"
    And I click "Save"
    Then I should see "The product was updated successfully." within the notification area
    And I should see the following product table
      | SKU    | Description    | Price |
      | 123456 | Premium Widget | 24.99 |
