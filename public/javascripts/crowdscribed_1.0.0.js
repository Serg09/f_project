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
      $scope.purchasePath = csConfiguration.get('purchasePath');
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
      $scope.errors = [];

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
                var message = "Unable to initialiaze the payment.";
                switch(error.code) {
                  case 'HOSTED_FIELDS_EMPTY':
                    message = 'All fields are empty';
                    break;
                  case 'HOSTED_FIELDS_INVALID':
                    message = 'Some fields are invalid';
                    break;
                  case 'HOSTED_FIELDS_FAILED_TOKENIZATION':
                    message = 'Tokenization failed. Card may be invalid';
                    break;
                  case 'HOSTED_FIELDS_TOKENIZATION_NETWORK_ERROR':
                    message = 'Network error tokenizing the payment';
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
            console.log("unable to submit the order");
            consoel.log(error);
            d.reject();
          });
          return d.promise;
        });
      });

      $scope.submitPayment = function() {
        $rootScope.submission.start();
        workflow.execute('submission').then(function() {
          $rootScope.submission.complete();
        }, function(response) {
          $rootScope.submission.fail();
          $scope.errors.push(response.data.message);
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

      $rootScope.countries = [
        { name: "Albania", abbreviation: "AL"},
        { name: "Algeria", abbreviation: "DZ"},
        { name: "Andorra", abbreviation: "AD"},
        { name: "Angola", abbreviation: "AO"},
        { name: "Argentina", abbreviation: "AR"},
        { name: "Armenia", abbreviation: "AM"},
        { name: "Aruba", abbreviation: "AW"},
        { name: "Australia", abbreviation: "AU"},
        { name: "Austria", abbreviation: "AT"},
        { name: "Azerbaijan", abbreviation: "AZ"},
        { name: "Azores", abbreviation: "PT"},
        { name: "Bahamas", abbreviation: "BS"},
        { name: "Bahrain", abbreviation: "BH"},
        { name: "Bangladesh", abbreviation: "BD"},
        { name: "Barbados", abbreviation: "BB"},
        { name: "Belarus", abbreviation: "BY"},
        { name: "Belgium", abbreviation: "BE"},
        { name: "Belize", abbreviation: "BZ"},
        { name: "Benin", abbreviation: "BJ"},
        { name: "Bermuda", abbreviation: "BM"},
        { name: "Bhutan", abbreviation: "BT"},
        { name: "Bolivia", abbreviation: "BO"},
        { name: "Bosna-Herzegovina", abbreviation: "BA"},
        { name: "Botswana", abbreviation: "BW"},
        { name: "Brazil", abbreviation: "BR"},
        { name: "Brunei Darussalam", abbreviation: "BN"},
        { name: "Bulgaria", abbreviation: "BG"},
        { name: "Burkina FASO", abbreviation: "BF"},
        { name: "Burundi", abbreviation: "BI"},
        { name: "Cambodia", abbreviation: "KH"},
        { name: "Cameroon", abbreviation: "CM"},
        { name: "Canada", abbreviation: "CA"},
        { name: "Cape Verde", abbreviation: "CV"},
        { name: "Cayman Islands", abbreviation: "KY"},
        { name: "Cntl African Republic", abbreviation: "CF"},
        { name: "Chad", abbreviation: "TS"},
        { name: "Chile", abbreviation: "CL"},
        { name: "China", abbreviation: "CN"},
        { name: "Colombia", abbreviation: "CO"},
        { name: "Democratic Republic of Congo", abbreviation: "CD"},
        { name: "Republic of the Congo (Brazaville)", abbreviation: "CG"},
        { name: "Corsica", abbreviation: "FR"},
        { name: "Costa Rica", abbreviation: "CR"},
        { name: "Cote d'Ivoire (Ivory Coast)", abbreviation: "CI"},
        { name: "Croatia", abbreviation: "HR"},
        { name: "Cyprus", abbreviation: "CY"},
        { name: "Czech Republic", abbreviation: "CZ"},
        { name: "Denmark", abbreviation: "DK"},
        { name: "Djibouti", abbreviation: "DJ"},
        { name: "Dominican Republic", abbreviation: "DO"},
        { name: "Ecuador", abbreviation: "EC"},
        { name: "Egypt", abbreviation: "EG"},
        { name: "El Salvador", abbreviation: "SV"},
        { name: "Equatorial Guinea", abbreviation: "GQ"},
        { name: "Eritrea", abbreviation: "ER"},
        { name: "Estonia", abbreviation: "EE"},
        { name: "Ethiopia", abbreviation: "ET"},
        { name: "Faroe Islands", abbreviation: "DK"},
        { name: "Fiji", abbreviation: "FJ"},
        { name: "Finland", abbreviation: "FI"},
        { name: "France", abbreviation: "FR"},
        { name: "French Guiana", abbreviation: "GF"},
        { name: "French Polynesia (Tahitti)", abbreviation: "PF"},
        { name: "Gabon", abbreviation: "GA"},
        { name: "Georgia, Republic of", abbreviation: "GE"},
        { name: "Germany", abbreviation: "DE"},
        { name: "Ghana", abbreviation: "GH"},
        { name: "Great Britain & Northern Ireland", abbreviation: "GB"},
        { name: "Greece", abbreviation: "GR"},
        { name: "Grenada", abbreviation: "GD"},
        { name: "Guadeloupe", abbreviation: "GP"},
        { name: "Guatemala", abbreviation: "GT"},
        { name: "Guinea", abbreviation: "GN"},
        { name: "Guinea-Bissau", abbreviation: "GW"},
        { name: "Guyana", abbreviation: "GY"},
        { name: "Haiti", abbreviation: "HT"},
        { name: "Honduras", abbreviation: "HN"},
        { name: "Hong Kong", abbreviation: "HK"},
        { name: "Hungary", abbreviation: "HU"},
        { name: "Iceland", abbreviation: "IS"},
        { name: "India", abbreviation: "IN"},
        { name: "Indonesia", abbreviation: "ID"},
        { name: "Iran", abbreviation: "IR"},
        { name: "Iraq", abbreviation: "IQ"},
        { name: "Ireland (Eire)", abbreviation: "IE"},
        { name: "Israel", abbreviation: "IL"},
        { name: "Italy", abbreviation: "IT"},
        { name: "Jamaica", abbreviation: "JM"},
        { name: "Japan", abbreviation: "JP"},
        { name: "Jordan", abbreviation: "JO"},
        { name: "Kazakhstan", abbreviation: "KZ"},
        { name: "Kenya", abbreviation: "KE"},
        { name: "South Korea, Republic of", abbreviation: "KR"},
        { name: "Kuwait", abbreviation: "KW"},
        { name: "Kyrgyzstan", abbreviation: "KG"},
        { name: "Laos", abbreviation: "LA"},
        { name: "Latvia", abbreviation: "LV"},
        { name: "Lesotho", abbreviation: "LS"},
        { name: "Liberia", abbreviation: "LR"},
        { name: "Liechtenstein", abbreviation: "LI"},
        { name: "Lithuania", abbreviation: "LT"},
        { name: "Luxembourg", abbreviation: "LU"},
        { name: "Macau", abbreviation: "MO"},
        { name: "Macedonia, Republic of", abbreviation: "MK"},
        { name: "Madagascar", abbreviation: "MG"},
        { name: "Madeira Islands", abbreviation: "PT"},
        { name: "Malawi", abbreviation: "MW"},
        { name: "Malaysia", abbreviation: "MY"},
        { name: "Maldives", abbreviation: "MV"},
        { name: "Mali", abbreviation: "ML"},
        { name: "Malta", abbreviation: "MT"},
        { name: "Martinique", abbreviation: "MQ"},
        { name: "Mauritania", abbreviation: "MR"},
        { name: "Mauritius", abbreviation: "MU"},
        { name: "Mexico", abbreviation: "MX"},
        { name: "Moldova", abbreviation: "MD"},
        { name: "Mongolia", abbreviation: "MN"},
        { name: "Morocco", abbreviation: "MA"},
        { name: "Mozambique", abbreviation: "MZ"},
        { name: "Namibia", abbreviation: "NA"},
        { name: "Nauru", abbreviation: "NR"},
        { name: "Nepal", abbreviation: "NP"},
        { name: "Netherlands (Holland)", abbreviation: "NL"},
        { name: "Netherlands Antilles", abbreviation: "AN"},
        { name: "New Caledonia", abbreviation: "NC"},
        { name: "New Zealand", abbreviation: "NZ"},
        { name: "Nicaragua", abbreviation: "NI"},
        { name: "Niger", abbreviation: "NE"},
        { name: "Nigeria", abbreviation: "NG"},
        { name: "Norway", abbreviation: "NO"},
        { name: "Oman", abbreviation: "OM"},
        { name: "Pakistan", abbreviation: "PK"},
        { name: "Panama", abbreviation: "PA"},
        { name: "Papua New Guinea", abbreviation: "PG"},
        { name: "Paraguay", abbreviation: "PY"},
        { name: "Peru", abbreviation: "PE"},
        { name: "Philippines", abbreviation: "PH"},
        { name: "Poland", abbreviation: "PL"},
        { name: "Portugal", abbreviation: "PT"},
        { name: "Qatar", abbreviation: "QA"},
        { name: "Romania", abbreviation: "RO"},
        { name: "Russia (Russia Federation)", abbreviation: "RU"},
        { name: "Rwanda", abbreviation: "RW"},
        { name: "St. Christopher (St. Kitts) and Nevis", abbreviation: "KN"},
        { name: "St. Lucia", abbreviation: "LC"},
        { name: "St. Vincent and the Grenadines", abbreviation: "VC"},
        { name: "Saudi Arabia", abbreviation: "SA"},
        { name: "Senegal", abbreviation: "SN"},
        { name: "Serbia Montenegro (Yugoslavia)", abbreviation: "YU"},
        { name: "Seychelles", abbreviation: "SC"},
        { name: "Sierra Leone", abbreviation: "SL"},
        { name: "Singapore", abbreviation: "SG"},
        { name: "Slovak Republic (Slovakia)", abbreviation: "SK"},
        { name: "Slovenia", abbreviation: "SI"},
        { name: "Solomon Islands", abbreviation: "SB"},
        { name: "Somalia", abbreviation: "SO"},
        { name: "South Africa", abbreviation: "ZA"},
        { name: "South Sudan", abbreviation: "SS"},
        { name: "Spain", abbreviation: "ES"},
        { name: "Sri Lanka", abbreviation: "LK"},
        { name: "Sudan", abbreviation: "SD"},
        { name: "Swaziland", abbreviation: "SZ"},
        { name: "Sweden", abbreviation: "SE"},
        { name: "Switzerland", abbreviation: "CH"},
        { name: "Syrian Arab Republic", abbreviation: "SY"},
        { name: "Taiwan", abbreviation: "TW"},
        { name: "Tajikistan", abbreviation: "TJ"},
        { name: "Tanzania", abbreviation: "TZ"},
        { name: "Thailand", abbreviation: "TH"},
        { name: "Togo", abbreviation: "TG"},
        { name: "Trinidad & Tobago", abbreviation: "TT"},
        { name: "Tunisia", abbreviation: "TN"},
        { name: "Turkey", abbreviation: "TR"},
        { name: "Turkmenistan", abbreviation: "TM"},
        { name: "Uganda", abbreviation: "UG"},
        { name: "Ukraine", abbreviation: "UA"},
        { name: "United Arab Emirates", abbreviation: "AE"},
        { name: "United States of America", abbreviation: "US"},
        { name: "Uruguay", abbreviation: "UY"},
        { name: "Vanuatu", abbreviation: "VU"},
        { name: "Venezuela", abbreviation: "VE"},
        { name: "Vietnam", abbreviation: "VN"},
        { name: "Western Samoa", abbreviation: "WS"},
        { name: "Yemen", abbreviation: "YE"}
      ];
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
              $rootScope.order.items.push(response.data);
            }, function(error) {
              console.log("Unable to add the item to the order.");
              console.log(error);
            });
          }
        } else {
          // they've already finished this order, create a new one
          cs.createOrder().then(handleOrder, function(error) {
            console.log("Unable to create an order");
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

(function() {
  function CsConfiguration() {
    this.settings = {};
  }
  CsConfiguration.prototype = {
    push: function(key, value) {
      this.settings[key] = value;
    },
    get: function(key) {
      return this.settings[key];
    }
  };
  window.csConfiguration = new CsConfiguration();
})();
