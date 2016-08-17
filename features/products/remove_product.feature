Feature: Remove a product
  As an administrator
  In order to remove a product added by mistake
  I need to be able to delete the product record

  Scenario: An administrator removes a product
    Given there are the following products
      | SKU    | Description    | Price |
      | 123456 | Deluxe Widget  | 19.99 |
      | 654321 | Premium Widget | 19.99 |

    Given there is a user with email "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Products" within the menu

    When I click "Products" within the menu
    Then I should see "Products" within the page title
    And I should see the following product table
      | SKU    | Description    | Price |
      | 123456 | Deluxe Widget  | 19.99 |
      | 654321 | Premium Widget | 19.99 |

    When I click the delete button within the 1st product row
    Then I should see "The product was removed successfully." within the notification area
    And I should see the following product table
      | SKU    | Description    | Price |
      | 654321 | Premium Widget | 19.99 |
