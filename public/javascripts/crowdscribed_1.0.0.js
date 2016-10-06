(function() {
  if (typeof window.angular === 'undefined') {
    console.log("The angular library has not been reference correctly. Please reference it and then continue.");
    return;
  }

  var HOST = 'http://localhost:3030';

  angular.module('crowdscribed', [])
    .directive('purchaseTile', ['$sce', function($sce) {
      // -------------
      // Purchase Tile
      // -------------
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl(HOST + '/templates/purchase_tile.html')
      } // TODO Put in the proper domain name
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
    .factory('cs', ['$http', function($http) {
      // --------------------
      // Crowdscribed Service
      // --------------------
      this.getProduct = function(sku, callback) {
        // TODO Put in the proper domain name
        var url = HOST + '/api/v1/products/' + sku;
        $http.get(url, {
          headers: {
            'Authorization': 'Token token=fde100e5505140c5a93cede29321cd9c'
          }
        }).then(function(response) {
          callback(response.data);
        }, function(error) {
          console.log("Unable to get the product.");
          console.log(error);
        });
      }
      this.getPaymentToken = function(callback) {
        var url = HOST + '/api/v1/tokens';
        $http.post(url, {
        }).then(function(response) {
          callback(response.data.token);
        }, function(error) {
          console.log("Unable to get a payment token.");
          console.log(error);
        });
      }
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
    .controller('purchaseController', ['$scope', 'cs', function($scope, cs) {
      cs.getPaymentToken(function(token) {
        braintree.setup(token, 'custom',
          id: 'payment-form',
          onPaymentMethodReceived: function(details) {
          },
          hostedFields: {
            number: {
              selector: '#card-number'
            }
          }
      )});
    }]);
})();
