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

  var m = angular.module('crowdscribed', ['ngCookies'])
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
    .directive('addressTile', ['$sce', function($sce) {
      // ------------
      // Address Tile
      // ------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(HOST + '/templates/address_tile.html')
      }
    }])
    .factory('cs', ['$http', function($http) {
      // --------------------
      // Crowdscribed Service
      // --------------------
      this.getProduct = function(sku) {
        // TODO Put in the proper domain name
        var url = HOST + '/api/v1/products/' + sku;
        return $http.get(url, HTTP_CONFIG);
      }
      this.getPaymentToken = function() {
        var url = HOST + '/api/v1/payments/token';
        return $http.get(url, HTTP_CONFIG);
      };
      this.createOrder = function() {
        var url = HOST + '/api/v1/orders'
        return $http.post(url, {order: {}}, HTTP_CONFIG);
      };
      this.getOrder = function(orderId) {
        var url = HOST + '/api/v1/orders/' + orderId
        return $http.get(url, HTTP_CONFIG);
      };
      this.updateOrder = function(order) {
        var url = HOST + '/api/v1/orders/' + order.id;
        data = {
          order: order,
          shipping_address: order.shipping_address
        }
        if(!order.customer_name && order.shipping_address.recipient) {
          order.customer_name = order.shipping_address.recipient
        }
        order.shipping_address = null;
        return $http.patch(url, data, HTTP_CONFIG);
      };
      this.addItem = function(orderId, sku, quantity) {
        var url = HOST + '/api/v1/orders/' + orderId + '/items';
        var data = {
          item: {
            sku: sku,
            quantity: quantity
          }
        };
        return $http.post(url, data, HTTP_CONFIG);
      };
      this.submitOrder = function(orderId) {
        var url = HOST + '/api/v1/orders/' + orderId + '/submit';
        return $http.patch(url, {order: {}}, HTTP_CONFIG);
      };
      this.createPayment = function(orderId, nonce) {
        var url = HOST + '/api/v1/orders/' + orderId + '/payments';
        var data = {
          payment: {
            nonce: nonce
          }
        };
        return $http.post(url, data, HTTP_CONFIG);
      };
      return this;
    }])
    .factory('workflow', ['$q', function($q) {
      var workflows = {};

      var getOrCreateWorkflow = function(workflow) {
        var result = workflows[workflow];
        if (typeof result === 'undefined') {
          result = [];
          workflows[workflow] = result;
        }
        return result;
      };

      this.create = function(workflow, callback) {
        var steps = getOrCreateWorkflow(workflow);
        callback(steps);
      };

      this.addStep = function(workflow, fn) {
        var steps = getOrCreateWorkflow(workflow);
        steps.push(fn);
      };

      var processStep = function(deferred, steps, index) {
        if (index < steps.length) {
          steps[index]().then(function(result) {
            deferred.notify(index);
            processStep(deferred, steps, index + 1);
          }, function(error) {
            deferred.reject(error);
          });
        } else {
          deferred.resolve();
        }
      };

      this.execute = function(workflow) {
        var d = $q.defer();
        steps = workflows[workflow];
        if (typeof steps === 'undefined') {
          d.reject("Workflow '" + workflow + "' is undefined.");
        } else {
          processStep(d, steps, 0);
        }
        return d.promise;
      };

      return this;
    }])
    .controller('purchaseTileController', ['$scope', 'cs', function($scope, cs) {
      // ------------------------
      // Purchase Tile Controller
      // ------------------------
      $scope.$watch('sku', function(newValue, oldValue) {
        cs.getProduct(newValue).then(function(response) {
          $scope.price = response.data.price;
        });
      });
      $scope.price = 0;
    }])
    .controller('paymentController', ['$rootScope', '$scope', '$q', 'cs', 'workflow', function($rootScope, $scope, $q, cs, workflow) {

      var StateMachine = function() {
        this.state = "unstarted";
      };
      StateMachine.prototype = {
        isUnstarted: function() {
          return this.state == "unstarted";
        },
        isInProgress: function() {
          return this.state == "in-progress";
        },
        isComplete: function() {
          return this.state == "complete";
        },
        isFailued: function() {
          return this.state == "failed";
        },
        start: function() {
          this.state = "in-progress";
        },
        complete: function() {
          this.state = "complete";
        },
        fail: function() {
          this.state = "failed";
        }
      };

      $rootScope.submission = new StateMachine();

      workflow.create('submission', function(wf) {
        // update order
        wf.push(function() {
          return cs.updateOrder($rootScope.order);
        });
        // tokenize payment method
        wf.push(function() {
          var d = $q.defer();
          if (typeof $scope.hostedFields === 'undefined') {
            d.reject("hostedFields has no value");
          } else {
            $scope.hostedFields.tokenize(function(error, payload) {
              if (error) {
                d.reject(error);
              } else {
                $scope.nonce = payload.nonce;
                d.resolve();
              }
            });
          }
          return d.promise;
        });
        // create payment
        wf.push(function() {
          return cs.createPayment($rootScope.order.id, $scope.nonce);
        });
        // submit order
        wf.push(function() {
          return cs.submitOrder($rootScope.order.id);
        });
      });

      $scope.submitPayment = function() {
        $rootScope.submission.start();
        workflow.execute('submission').then(function() {
          $rootScope.submission.complete();
        }, function(error) {
          $rootScope.submission.fail();
          console.log("Unable to complete the submission.");
          console.log(error);
        }, function(index) {
          console.log("processed step " + index);
        });
      };

      cs.getPaymentToken().then(function(response) {
        braintree.client.create({authorization: response.data.token}, function(error, client) {
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

            $scope.hostedFields = hostedFields;
          });
        });
      });
    }]) // paymentController
    .controller('cartController', ['$rootScope', '$cookies', '$location', 'cs', function($rootScope, $cookies, $location, cs) {
      // Find the existing order or create a new order
      var orderId = $cookies.get('order_id');

      var itemIsInOrder = function(sku) {
        var found = _.find($rootScope.order.items, function(item) {
          return item.sku == sku;
        });
        return found != null;
      };

      var handleOrder = function(response) {
        $rootScope.order = response.data;
        if ($rootScope.order.id)
          $cookies.put('order_id', $rootScope.order.id);
        if (!$rootScope.order.shipping_address) {
          $rootScope.order.shipping_address = {};
        }
        if (!$rootScope.order.items) {
          $rootScope.order.items = [];
        }
        $rootScope.orderTotal = _.reduce(
            $rootScope.order.items,
            function(sum, item) {
              return sum + item.extended_price;
            }, 0);

        var sku = $location.search()['sku'];
        if (sku && !itemIsInOrder(sku)) {
          var quantity = $location.search()['quantity'] || 1;
          cs.addItem($rootScope.order.id, sku, quantity).then(function(response) {
            $rootScope.order.items.push(response.data);
          }, function(error) {
            console.log("Unable to add the item to the order.");
            console.log(error);
          });
        }
      };

      if ((typeof orderId) === "undefined") {
        cs.createOrder().then(handleOrder, function(error) {
          console.log("Unable to create an order");
          console.log(error);
        });
      } else {
        cs.getOrder(orderId).then(handleOrder, function(error) {
          console.log("Unable to get the order " + orderId);
          console.log(error);
        });
      }
    }]); // controller('cartController')
})();
