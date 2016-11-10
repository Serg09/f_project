@wip
Feature: View payments for an order
  As a user
  In order to get information about payment
  I need to be able to view payments for an order

  Scenario: A user views payments for an order
    Given "Joe Schmoe" ordered "046853712-0" - "Fair Stood the Wind for France" for $19.99 on 2/27/2016
    And "Joe Schmoe" paid for and submitted his order

    And there is a user with email address "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Orders" within the page title

    When I click "Submitted" within the secondary menu
    And I should see the following order table
      | Order date | Customer name |  Total |
      |  2/27/2016 | Joe Schmoe    | $21.64 |

    When I click the view button within the 1st order row
    Then I should see "Order" within the page title
    And I should see the following payments table
      | Payment date | State    | External ID | Amount |
      |    2/27/2016 | approved | ehsr70f9    |  27.05 |

    When I click the view button within the first payment row
    Then I should see "Payment" within the page title
    And I see "Transactions" within the main content
