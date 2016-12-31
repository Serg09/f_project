Feature: View orders
  As a user,
  In order to know the status of orders
  I need to be able to view them in the website

  Scenario: A user views the list of orders
    Given "Joe Schmoe" ordered "046853712-0" - "Fair Stood the Wind for France" for $19.99 on 2/27/2016
    And "Sally Readerton" ordered "386112213-8" - "Quo Vadis" for $24.99 on 3/2/2016
    And "Billy Bookworm" ordered "736487956-0" - "Wildfire at Midnight" for $17.99 on 1/17/2016

    And there is a user with email address "john@doe.com" and password "please01"
    And I am signed in as "john@doe.com/please01"

    When I am on the home page
    Then I should see "Orders" within the menu

    When I click "Orders" within the menu
    Then I should see "Orders" within the page title
    And I should see the following order table
      | Order date | Customer name   |  Total |
      |   3/2/2016 | Sally Readerton | $32.05 |
      |  2/27/2016 | Joe Schmoe      | $26.64 |
      |  1/17/2016 | Billy Bookworm  | $24.47 |
