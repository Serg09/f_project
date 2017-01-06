(function() {
  if (typeof window.angular === 'undefined') {
    console.log("The angular library has not been reference correctly. Please reference it and then continue.");
    return;
  }

  angular.module('crowdscribed', ['ngCookies', 'ui.bootstrap'])
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
        templateUrl: $sce.trustAsResourceUrl(CROWDSCRIBED_HOST + '/templates/purchase_tile.html'),
        scope: {
          sku: '=sku',
          caption: '=caption'
        }
      }
    }])
    .directive('multiPurchaseTile', ['$sce', function($sce) {
      // -------------------
      // Multi-Purchase Tile
      // -------------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(CROWDSCRIBED_HOST + '/templates/multi_purchase_tile.html'),
        scope: {
          products: '=products',
        }
      }
    }])
    .directive('paymentTile', ['$sce', function($sce) {
      // ------------
      // Payment Tile
      // ------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(CROWDSCRIBED_HOST + '/templates/payment_tile.html')
      }
    }])
    .directive('cartTile', ['$sce', function($sce) {
      // ---------
      // Cart Tile
      // ---------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(CROWDSCRIBED_HOST + '/templates/cart_tile.html')
      }
    }])
    .directive('addressTile', ['$sce', function($sce) {
      // ------------
      // Address Tile
      // ------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(CROWDSCRIBED_HOST + '/templates/address_tile.html')
      }
    }])
    .directive('confirmationTile', ['$sce', function($sce) {
      // -----------------
      // Confrimation Tile
      // -----------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(CROWDSCRIBED_HOST + '/templates/confirmation_tile.html')
      }
    }])
    .factory('cs', ['$http', function($http) {

      var httpConfig = {
        headers: {
          'Authorization': 'Token token=' + CROWDSCRIBED_AUTH_TOKEN,
          'Content-Type': 'application/json'
        }
      };

      // --------------------
      // Crowdscribed Service
      // --------------------
      this.getShipMethods = function() {
        var url = CROWDSCRIBED_HOST + '/api/v1/ship_methods';
        return $http.get(url, httpConfig);
      };
      this.getProduct = function(sku) {
        // TODO Put in the proper domain name
        var url = CROWDSCRIBED_HOST + '/api/v1/products/' + sku;
        return $http.get(url, httpConfig);
      };
      this.getPaymentToken = function() {
        var url = CROWDSCRIBED_HOST + '/api/v1/payments/token';
        return $http.get(url, httpConfig);
      };
      this.createOrder = function() {
        var url = CROWDSCRIBED_HOST + '/api/v1/orders'
        return $http.post(url, {order: {}}, httpConfig);
      };
      this.getOrder = function(orderId) {
        var url = CROWDSCRIBED_HOST + '/api/v1/orders/' + orderId
        return $http.get(url, httpConfig);
      };
      this.updateOrder = function(order) {
        var url = CROWDSCRIBED_HOST + '/api/v1/orders/' + order.id;
        var clone = _.clone(order);
        clone.shipping_address = null
        data = {
          order: clone,
          shipping_address: order.shipping_address
        }
        return $http.patch(url, data, httpConfig);
      };
      this.addItem = function(orderId, sku, quantity) {
        var url = CROWDSCRIBED_HOST + '/api/v1/orders/' + orderId + '/items';
        var data = {
          item: {
            sku: sku,
            quantity: quantity
          }
        };
        return $http.post(url, data, httpConfig);
      };
      this.updateItem = function(item) {
        var url = CROWDSCRIBED_HOST + '/api/v1/order_items/' + item.id;
        return $http.patch(url, { item: item }, httpConfig);
      };
      this.removeItem = function(itemId) {
        var url = CROWDSCRIBED_HOST + '/api/v1/order_items/' + itemId;
        return $http.delete(url, httpConfig);
      };
      this.submitOrder = function(orderId) {
        var url = CROWDSCRIBED_HOST + '/api/v1/orders/' + orderId + '/submit';
        return $http.patch(url, {order: {}}, httpConfig);
      };
      this.createPayment = function(orderId, nonce) {
        var url = CROWDSCRIBED_HOST + '/api/v1/orders/' + orderId + '/payments';
        var data = {
          payment: {
            nonce: nonce
          }
        };
        return $http.post(url, data, httpConfig);
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

      // Lookup the price
      cs.getProduct($scope.sku).then(function(response) {
        if(response.data) {
          $scope.price = response.data.price;
        }
      });

      $scope.price = 0;
      $scope.purchasePath = CROWDSCRIBED_PURCHASE_PATH;
    }])
    .controller('multiPurchaseTileController', ['$scope', 'cs', function($scope, cs) {
      // ------------------------------
      // Multi Purchase Tile Controller
      // ------------------------------

      console.log("products");
      console.log($scope.products);

      _.each($scope.products, function(product) {
        cs.getProduct(product.sku).then(function(response) {
          product.caption = product.caption + " - " + response.data.price;
        });
      });
      $scope.selectedSku = $scope.products[0].sku;
      $scope.purchasePath = CROWDSCRIBED_PURCHASE_PATH;
    }])
    .controller('paymentController', ['$rootScope', '$scope', '$q', '$uibModal', '$sce', 'cs', 'workflow', function($rootScope, $scope, $q, $uibModal, $sce, cs, workflow) {
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
      $rootScope.errors = [];
      $scope.removeError = function(error) {
        var index = $rootScope.errors.indexOf(error);
        $rootScope.errors.splice(index, index+1);
      };

      workflow.create('submission', function(wf) {
        // update order
        wf.push(function() {
          var o = $rootScope.order
          if(!o.customer_name && o.shipping_address.recipient) {
            o.customer_name = o.shipping_address.recipient
          }
          return cs.updateOrder(o);
        });
        // tokenize payment method
        wf.push(function() {
          var d = $q.defer();
          if (typeof $scope.hostedFields === 'undefined') {
            d.reject("hostedFields has no value");
          } else {
            $scope.hostedFields.tokenize(function(error, payload) {
              if (error) {
                var message = "Unable to create the payment. Please try again.";
                switch(error.code) {
                  case 'HOSTED_FIELDS_EMPTY':
                    message = 'All payment fields are empty. Please supply appropriate values.';
                    break;
                  case 'HOSTED_FIELDS_INVALID':
                    message = 'Some payment fields are invalid. Please doubl check them and try again.';
                    break;
                  case 'HOSTED_FIELDS_FAILED_TOKENIZATION':
                    message = 'Payment failed. Card may be invalid';
                    break;
                  case 'HOSTED_FIELDS_TOKENIZATION_NETWORK_ERROR':
                    message = 'There was a network error creating the payment.';
                    break;
                }
                d.reject({data: {message: message}});
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
          var d = $q.defer();
          cs.createPayment($rootScope.order.id, $scope.nonce).then(function(response) {
            $rootScope.payment = response.data;
            d.resolve(response);
          }, function(error) {
            d.reject(error);
          });
          return d.promise;
        });
        // submit order
        wf.push(function() {
          var d = $q.defer();
          cs.submitOrder($rootScope.order.id).then(function(response) {
            $rootScope.order = response.data;
            d.resolve();
          }, function(error) {
            $rootScope.errors.push("Unable to submit the order.");
            d.reject();
          });
          return d.promise;
        });
      });

      $scope.readyToSubmit = function() {
        if (typeof $rootScope.order === "undefined") {
          return false;
        }
        var o = $rootScope.order;
        return o.customer_email != null &&
          typeof(o.shipping_address) !== "undefined" &&
          o.shipping_address != null &&
          o.shipping_address.recipient != null &&
          o.shipping_address.line_1 != null &&
          o.shipping_address.city != null &&
          o.shipping_address.state != null &&
          o.shipping_address.postal_code != null &&
          o.shipping_address.country_code != null &&
          o.telephone != null &&
          o.ship_method_id != null;
      };

      $scope.preventSubmission = function() {
        return !$scope.readyToSubmit();
      };

      $scope.submitPayment = function() {
        $rootScope.errors.length = 0;
        if ($scope.preventSubmission()) {
          $rootScope.errors.push("Your order has not yet gone through. Please complete the required fields in order to process your order.");
        } else {
          var modalInstance = $uibModal.open({
            templateUrl: $sce.trustAsResourceUrl(CROWDSCRIBED_HOST + '/templates/progress.html'),
            keyboard: false,
            backdrop: 'static'
          });
          $rootScope.submission.start();
          workflow.execute('submission').then(function() {
            $rootScope.submission.complete();
            modalInstance.close();
          }, function(error) {
            $rootScope.submission.fail();
            if (typeof(error) !== "undefined") {
              $rootScope.errors.push(error);
            }
            modalInstance.close();
          });
        }
      };

      cs.getPaymentToken().then(function(response) {
        braintree.client.create({authorization: response.data.token}, function(error, client) {
          if (error) {
            $rootScope.errors.push("Unable to set up the payment form.");
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
              $rootScope.errors.push("Unable to set up the payment fields.");
              return;
            }

            // add CC field events here

            $scope.hostedFields = hostedFields;
          });
        });
      });

      $rootScope.countries = [
        //{ name: "Albania", abbreviation: "AL"},
        //{ name: "Algeria", abbreviation: "DZ"},
        //{ name: "Andorra", abbreviation: "AD"},
        //{ name: "Angola", abbreviation: "AO"},
        //{ name: "Argentina", abbreviation: "AR"},
        //{ name: "Armenia", abbreviation: "AM"},
        //{ name: "Aruba", abbreviation: "AW"},
        //{ name: "Australia", abbreviation: "AU"},
        //{ name: "Austria", abbreviation: "AT"},
        //{ name: "Azerbaijan", abbreviation: "AZ"},
        //{ name: "Azores", abbreviation: "PT"},
        //{ name: "Bahamas", abbreviation: "BS"},
        //{ name: "Bahrain", abbreviation: "BH"},
        //{ name: "Bangladesh", abbreviation: "BD"},
        //{ name: "Barbados", abbreviation: "BB"},
        //{ name: "Belarus", abbreviation: "BY"},
        //{ name: "Belgium", abbreviation: "BE"},
        //{ name: "Belize", abbreviation: "BZ"},
        //{ name: "Benin", abbreviation: "BJ"},
        //{ name: "Bermuda", abbreviation: "BM"},
        //{ name: "Bhutan", abbreviation: "BT"},
        //{ name: "Bolivia", abbreviation: "BO"},
        //{ name: "Bosna-Herzegovina", abbreviation: "BA"},
        //{ name: "Botswana", abbreviation: "BW"},
        //{ name: "Brazil", abbreviation: "BR"},
        //{ name: "Brunei Darussalam", abbreviation: "BN"},
        //{ name: "Bulgaria", abbreviation: "BG"},
        //{ name: "Burkina FASO", abbreviation: "BF"},
        //{ name: "Burundi", abbreviation: "BI"},
        //{ name: "Cambodia", abbreviation: "KH"},
        //{ name: "Cameroon", abbreviation: "CM"},
        { name: "Canada", abbreviation: "CA"},
        //{ name: "Cape Verde", abbreviation: "CV"},
        //{ name: "Cayman Islands", abbreviation: "KY"},
        //{ name: "Cntl African Republic", abbreviation: "CF"},
        //{ name: "Chad", abbreviation: "TS"},
        //{ name: "Chile", abbreviation: "CL"},
        //{ name: "China", abbreviation: "CN"},
        //{ name: "Colombia", abbreviation: "CO"},
        //{ name: "Democratic Republic of Congo", abbreviation: "CD"},
        //{ name: "Republic of the Congo (Brazaville)", abbreviation: "CG"},
        //{ name: "Corsica", abbreviation: "FR"},
        //{ name: "Costa Rica", abbreviation: "CR"},
        //{ name: "Cote d'Ivoire (Ivory Coast)", abbreviation: "CI"},
        //{ name: "Croatia", abbreviation: "HR"},
        //{ name: "Cyprus", abbreviation: "CY"},
        //{ name: "Czech Republic", abbreviation: "CZ"},
        //{ name: "Denmark", abbreviation: "DK"},
        //{ name: "Djibouti", abbreviation: "DJ"},
        //{ name: "Dominican Republic", abbreviation: "DO"},
        //{ name: "Ecuador", abbreviation: "EC"},
        //{ name: "Egypt", abbreviation: "EG"},
        //{ name: "El Salvador", abbreviation: "SV"},
        //{ name: "Equatorial Guinea", abbreviation: "GQ"},
        //{ name: "Eritrea", abbreviation: "ER"},
        //{ name: "Estonia", abbreviation: "EE"},
        //{ name: "Ethiopia", abbreviation: "ET"},
        //{ name: "Faroe Islands", abbreviation: "DK"},
        //{ name: "Fiji", abbreviation: "FJ"},
        //{ name: "Finland", abbreviation: "FI"},
        //{ name: "France", abbreviation: "FR"},
        //{ name: "French Guiana", abbreviation: "GF"},
        //{ name: "French Polynesia (Tahitti)", abbreviation: "PF"},
        //{ name: "Gabon", abbreviation: "GA"},
        //{ name: "Georgia, Republic of", abbreviation: "GE"},
        //{ name: "Germany", abbreviation: "DE"},
        //{ name: "Ghana", abbreviation: "GH"},
        //{ name: "Great Britain & Northern Ireland", abbreviation: "GB"},
        //{ name: "Greece", abbreviation: "GR"},
        //{ name: "Grenada", abbreviation: "GD"},
        //{ name: "Guadeloupe", abbreviation: "GP"},
        //{ name: "Guatemala", abbreviation: "GT"},
        //{ name: "Guinea", abbreviation: "GN"},
        //{ name: "Guinea-Bissau", abbreviation: "GW"},
        //{ name: "Guyana", abbreviation: "GY"},
        //{ name: "Haiti", abbreviation: "HT"},
        //{ name: "Honduras", abbreviation: "HN"},
        //{ name: "Hong Kong", abbreviation: "HK"},
        //{ name: "Hungary", abbreviation: "HU"},
        //{ name: "Iceland", abbreviation: "IS"},
        //{ name: "India", abbreviation: "IN"},
        //{ name: "Indonesia", abbreviation: "ID"},
        //{ name: "Iran", abbreviation: "IR"},
        //{ name: "Iraq", abbreviation: "IQ"},
        //{ name: "Ireland (Eire)", abbreviation: "IE"},
        //{ name: "Israel", abbreviation: "IL"},
        //{ name: "Italy", abbreviation: "IT"},
        //{ name: "Jamaica", abbreviation: "JM"},
        //{ name: "Japan", abbreviation: "JP"},
        //{ name: "Jordan", abbreviation: "JO"},
        //{ name: "Kazakhstan", abbreviation: "KZ"},
        //{ name: "Kenya", abbreviation: "KE"},
        //{ name: "South Korea, Republic of", abbreviation: "KR"},
        //{ name: "Kuwait", abbreviation: "KW"},
        //{ name: "Kyrgyzstan", abbreviation: "KG"},
        //{ name: "Laos", abbreviation: "LA"},
        //{ name: "Latvia", abbreviation: "LV"},
        //{ name: "Lesotho", abbreviation: "LS"},
        //{ name: "Liberia", abbreviation: "LR"},
        //{ name: "Liechtenstein", abbreviation: "LI"},
        //{ name: "Lithuania", abbreviation: "LT"},
        //{ name: "Luxembourg", abbreviation: "LU"},
        //{ name: "Macau", abbreviation: "MO"},
        //{ name: "Macedonia, Republic of", abbreviation: "MK"},
        //{ name: "Madagascar", abbreviation: "MG"},
        //{ name: "Madeira Islands", abbreviation: "PT"},
        //{ name: "Malawi", abbreviation: "MW"},
        //{ name: "Malaysia", abbreviation: "MY"},
        //{ name: "Maldives", abbreviation: "MV"},
        //{ name: "Mali", abbreviation: "ML"},
        //{ name: "Malta", abbreviation: "MT"},
        //{ name: "Martinique", abbreviation: "MQ"},
        //{ name: "Mauritania", abbreviation: "MR"},
        //{ name: "Mauritius", abbreviation: "MU"},
        //{ name: "Mexico", abbreviation: "MX"},
        //{ name: "Moldova", abbreviation: "MD"},
        //{ name: "Mongolia", abbreviation: "MN"},
        //{ name: "Morocco", abbreviation: "MA"},
        //{ name: "Mozambique", abbreviation: "MZ"},
        //{ name: "Namibia", abbreviation: "NA"},
        //{ name: "Nauru", abbreviation: "NR"},
        //{ name: "Nepal", abbreviation: "NP"},
        //{ name: "Netherlands (Holland)", abbreviation: "NL"},
        //{ name: "Netherlands Antilles", abbreviation: "AN"},
        //{ name: "New Caledonia", abbreviation: "NC"},
        //{ name: "New Zealand", abbreviation: "NZ"},
        //{ name: "Nicaragua", abbreviation: "NI"},
        //{ name: "Niger", abbreviation: "NE"},
        //{ name: "Nigeria", abbreviation: "NG"},
        //{ name: "Norway", abbreviation: "NO"},
        //{ name: "Oman", abbreviation: "OM"},
        //{ name: "Pakistan", abbreviation: "PK"},
        //{ name: "Panama", abbreviation: "PA"},
        //{ name: "Papua New Guinea", abbreviation: "PG"},
        //{ name: "Paraguay", abbreviation: "PY"},
        //{ name: "Peru", abbreviation: "PE"},
        //{ name: "Philippines", abbreviation: "PH"},
        //{ name: "Poland", abbreviation: "PL"},
        //{ name: "Portugal", abbreviation: "PT"},
        //{ name: "Qatar", abbreviation: "QA"},
        //{ name: "Romania", abbreviation: "RO"},
        //{ name: "Russia (Russia Federation)", abbreviation: "RU"},
        //{ name: "Rwanda", abbreviation: "RW"},
        //{ name: "St. Christopher (St. Kitts) and Nevis", abbreviation: "KN"},
        //{ name: "St. Lucia", abbreviation: "LC"},
        //{ name: "St. Vincent and the Grenadines", abbreviation: "VC"},
        //{ name: "Saudi Arabia", abbreviation: "SA"},
        //{ name: "Senegal", abbreviation: "SN"},
        //{ name: "Serbia Montenegro (Yugoslavia)", abbreviation: "YU"},
        //{ name: "Seychelles", abbreviation: "SC"},
        //{ name: "Sierra Leone", abbreviation: "SL"},
        //{ name: "Singapore", abbreviation: "SG"},
        //{ name: "Slovak Republic (Slovakia)", abbreviation: "SK"},
        //{ name: "Slovenia", abbreviation: "SI"},
        //{ name: "Solomon Islands", abbreviation: "SB"},
        //{ name: "Somalia", abbreviation: "SO"},
        //{ name: "South Africa", abbreviation: "ZA"},
        //{ name: "South Sudan", abbreviation: "SS"},
        //{ name: "Spain", abbreviation: "ES"},
        //{ name: "Sri Lanka", abbreviation: "LK"},
        //{ name: "Sudan", abbreviation: "SD"},
        //{ name: "Swaziland", abbreviation: "SZ"},
        //{ name: "Sweden", abbreviation: "SE"},
        //{ name: "Switzerland", abbreviation: "CH"},
        //{ name: "Syrian Arab Republic", abbreviation: "SY"},
        //{ name: "Taiwan", abbreviation: "TW"},
        //{ name: "Tajikistan", abbreviation: "TJ"},
        //{ name: "Tanzania", abbreviation: "TZ"},
        //{ name: "Thailand", abbreviation: "TH"},
        //{ name: "Togo", abbreviation: "TG"},
        //{ name: "Trinidad & Tobago", abbreviation: "TT"},
        //{ name: "Tunisia", abbreviation: "TN"},
        //{ name: "Turkey", abbreviation: "TR"},
        //{ name: "Turkmenistan", abbreviation: "TM"},
        //{ name: "Uganda", abbreviation: "UG"},
        //{ name: "Ukraine", abbreviation: "UA"},
        //{ name: "United Arab Emirates", abbreviation: "AE"},
        { name: "United States of America", abbreviation: "US"}
        //{ name: "Uruguay", abbreviation: "UY"},
        //{ name: "Vanuatu", abbreviation: "VU"},
        //{ name: "Venezuela", abbreviation: "VE"},
        //{ name: "Vietnam", abbreviation: "VN"},
        //{ name: "Western Samoa", abbreviation: "WS"},
        //{ name: "Yemen", abbreviation: "YE"}
      ];
    }]) // paymentController
    .controller('cartController', ['$rootScope', '$cookies', '$location', 'cs', function($rootScope, $cookies, $location, cs) {

      // Look up ship methods
      cs.getShipMethods().then(function(response) {
        $rootScope.shipMethods = response.data;
      },
      function (error) {
        $rootScope.errors.push("Unable to get the ship methods from the service.");
      });

      $rootScope.updateFreightCharge = function() {
        order = $rootScope.order;
        if (order != null &&
            order.ship_method_id != null &&
            order.shipping_address.postal_code != null &&
            order.items.length != 0) {
          // it would also be good to know if the order has changed before
          // we start calling the service

          // maybe we need to block the app while this call happens?
          cs.updateOrder($rootScope.order).then(function(response) {
            $rootScope.order = response.data;
          },
          function(error) {
            $rootScope.errors.push("Unable to update the order in order update the freight charge.");
          });
        }
      };

      var refreshOrder = function() {
        cs.getOrder($rootScope.order.id).then(function(response) {
          $rootScope.order = response.data;
        }, function(error) {
          $rootScope.errors.push("Unable to get the updated order.");
        });
      };

      $rootScope.updateItem = function(item) {
        cs.updateItem(item).then(function(updatedItem) {
          refreshOrder();
        }, function(error) {
          $rootScope.errors.push("Unable to update the order item.");
        });
      };

      $rootScope.removeItem = function(item) {
        cs.removeItem(item.id).then(function() {
          refreshOrder();
        }, function(error) {
          $rootScope.errors.push("Unable to remove the item from the order.");
        });
      }

      $rootScope.canEditItemQuantity = function(item) {
        return item['standard_item?'] && !$rootScope.submission.isComplete();
      };

      // Find the existing order or create a new order
      var orderId = $cookies.get('order_id');

      var itemIsInOrder = function(sku) {
        var found = _.find($rootScope.order.items, function(item) {
          return item.sku == sku;
        });
        return found != null;
      };

      var handleOrder = function(response) {
        if (response.data.status == 'incipient') {
          $rootScope.order = response.data;
          if ($rootScope.order.id)
            $cookies.put('order_id', $rootScope.order.id);
          if (!$rootScope.order.shipping_address) {
            $rootScope.order.shipping_address = {country_code: 'US'};
          }
          if (!$rootScope.order.items) {
            $rootScope.order.items = [];
          }
          $rootScope.orderTotal = function() {
            return _.reduce(
              $rootScope.order.items,
              function(sum, item) {
                return sum + item.extended_price;
              }, 0);
          };

          var sku = $location.search()['sku'];
          if (sku && !itemIsInOrder(sku)) {
            var quantity = $location.search()['quantity'] || 1;
            cs.addItem($rootScope.order.id, sku, quantity).then(function(response) {
              refreshOrder();
            }, function(error) {
              $rootScope.errors.push("Unable to add the item to the order.");
            });
          }
        } else {
          // they've already finished this order, create a new one
          cs.createOrder().then(handleOrder, function(error) {
            $rootScope.errors.push("Unable to create an order");
          });
        }
      };

      if ((typeof orderId) === "undefined") {
        cs.createOrder().then(handleOrder, function(error) {
          $rootScope.errors.push("Unable to create an order");
        });
      } else {
        cs.getOrder(orderId).then(handleOrder, function(error) {
          $rootScope.errors.push("Unable to get the order.");
        });
      }
    }]); // controller('cartController')
})();
