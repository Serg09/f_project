(function() {
  if (typeof window.angular === 'undefined') {
    console.log("The angular library has not been reference correctly. Please reference it and then continue.");
    return;
  }

  var HOST = 'http://localhost:3030';
  var HTTP_CONFIG = {
    headers: {
      'Authorization': 'Token token=fde100e5505140c5a93cede29321cd9c',
      'Content-Type': 'application/json'
    }
  };

  angular.module('crowdscribed', ['ngCookies'])
    .config(['$locationProvider', function($locationProvider) {
      $locationProvider.html5Mode({enabled: true,
                                   requireBase: false});
    }])
    .directive('purchaseTile', ['$sce', function($sce) {
      // -------------
      // Purchase Tile
      // -------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(HOST + '/templates/purchase_tile.html')
      }
    }])
    .directive('paymentTile', ['$sce', function($sce) {
      // ------------
      // Payment Tile
      // ------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(HOST + '/templates/payment_tile.html')
      }
    }])
    .directive('cartTile', ['$sce', function($sce) {
      // ---------
      // Cart Tile
      // ---------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(HOST + '/templates/cart_tile.html')
      }
    }])
    .factory('cs', ['$http', function($http) {
      // --------------------
      // Crowdscribed Service
      // --------------------
      this.getProduct = function(sku, callback) {
        // TODO Put in the proper domain name
        var url = HOST + '/api/v1/products/' + sku;
        $http.get(url, HTTP_CONFIG).then(function(response) {
          callback(response.data);
        }, function(error) {
          console.log("Unable to get the product.");
          console.log(error);
        });
      }
      this.getPaymentToken = function(callback) {
        var url = HOST + '/api/v1/payments/token';
        $http.get(url, HTTP_CONFIG).then(function(response) {
          callback(response.data.token);
        }, function(error) {
          console.log("Unable to get a payment token.");
          console.log(error);
        });
      };
      this.createOrder = function(callback) {
        var url = HOST + '/api/v1/orders'
        $http.post(url, {order: {}}, HTTP_CONFIG).then(function(response) {
          callback(response.data);
        }, function(error) {
          console.log("Unable to create the order.");
          console.log(error);
        });
      };
      this.getOrder = function(orderId, callback) {
        var url = HOST + '/api/v1/orders/' + orderId
        $http.get(url, HTTP_CONFIG).then(function(response) {
          callback(response.data);
        }, function(error) {
          console.log("Unable to get the order " + orderId + ".");
          console.log(error);
        });
      };
      this.addItem = function(orderId, sku, quantity, callback) {
        var url = HOST + '/api/v1/orders/' + orderId + '/items';
        var data = {
          item: {
            sku: sku,
            quantity: quantity
          }
        };
        $http.post(url, data, HTTP_CONFIG).then(function(response) {
          callback(response.data);
        }, function(error) {
          console.log("Unable to add the order item " + sku + " to the order.");
          console.log(error);
        });
      };
      this.submitOrder = function(orderId, callback) {
        var url = HOST + '/api/v1/orders/' + orderId + '/submit';
        $http.patch(url, {order: {}}, HTTP_CONFIG).then(function(response) {
          callback({succeeded: true});
        }, function(error) {
          console.log("Unable to submit the order.");
          console.log(error);
          callback({succeeded: false, error: error});
        });
      };
      this.createPayment = function(orderId, nonce, callback) {
        var url = HOST + '/api/v1/orders/' + orderId + '/payments';
        var data = {
          payment: {
            nonce: nonce
          }
        };
        $http.post(url, data, HTTP_CONFIG).then(function(response) {
          callback({succeeded: true});
        }, function(error) {
          console.log("Unable to create the payment.");
          console.log(error);
          callback({succeeded: false, error: error});
        });
      };
      return this;
    }])
    .controller('purchaseTileController', ['$scope', 'cs', function($scope, cs) {
      // ------------------------
      // Purchase Tile Controller
      // ------------------------
      $scope.$watch('sku', function(newValue, oldValue) {
        cs.getProduct(newValue, function(product) {
          $scope.price = product.price;
        });
      });
    }])
    .controller('paymentController', ['$rootScope', 'cs', function($rootScope, cs) {
      cs.getPaymentToken(function(token) {
        braintree.client.create({authorization: token}, function(error, client) {
          if (error) {
            console.log("An error ocurred setting up the braintree client.");
            console.log(error);
            return;
          }

          braintree.hostedFields.create({
            client: client,
            styles: {
              'input': {
                'font-size': '12px',
                'height': '24px'
              }
            },
            fields: {
              number: {
                selector: '#card-number',
                placeholder: '4111 1111 1111 1111'
              },
              cvv: {
                selector: '#cvv',
                placeholder: '111'
              },
              expirationDate: {
                selector: '#expiration-date',
                placeholder: '12 / 22'
              }
            }
          }, function(error, hostedFields) {
            if (error) {
              console.log("An error ocurred setting up the hosted fields.");
              console.log(error);
              return;
            }

            // add CC field events here

            $('#payment-form').submit(function(event) {
              event.preventDefault();
              hostedFields.tokenize(function(error, payload) {
                if (error) {
                  console.log("An error ocurred tokenizing the payment method.");
                  console.log(error);
                  return;
                }
                cs.createPayment($rootScope.order.id, payload.nonce, function(result) {
                  if (result.succeeded) {
                    cs.submitOrder($rootScope.order.id, function(result) {
                      if (result.succeeded) {
                        $rootScope.confirmationNumber = $rootScope.order.id;

                        console.log("set $rootScope.confirmationNumber to " + $rootScope.confirmationNumber);
                      } else {
                        alert("We were unable to submit your order.\n" + result.error);
                      }
                    });
                  } else {
                    alert("Unable to submit the order.\n" + result.error);
                  }
                });
              }); // tokenize callback
            }); // submit
          }); // hostedFields.create
        }); // braintree.client.create
      }); // getPaymentToken
    }])
    .controller('cartController', ['$rootScope', '$cookies', '$location', 'cs', function($rootScope, $cookies, $location, cs) {
      // Find the existing order or create a new order
      var orderId = $cookies.get('order_id');

      this.submissionComplete = function() {
        return $rootScope.confirmationNumber != null;
      };

      var handleOrder = function(order) {
        $rootScope.order = order;
        if (order.id)
          $cookies.put('order_id', order.id);

        $rootScope.orderTotal = _.reduce($rootScope.order.items, function(sum, item) {
          return sum + item.extended_price;
        }, 0);

        var sku = $location.search()['sku'];
        if (sku) {
          var quantity = $location.search()['quantity'] || 1;
          cs.addItem(order.id, sku, quantity, function(item) {
            $rootScope.order.items.push(item);
          });
        }
      };

      if ((typeof orderId) === "undefined") {
        cs.createOrder(handleOrder);
      } else {
        cs.getOrder(orderId, handleOrder);
      }
    }]); // controller('paymentController')
})();
