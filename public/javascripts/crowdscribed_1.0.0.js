(function() {
  if (typeof window.angular === 'undefined') {
    console.log("The angular library has not been reference correctly. Please reference it and then continue.");
    return;
  }

  angular.module('crowdscribed', []).
    directive('purchaseTile', ['$sce', function($sce) {
      return {
        restrict: 'E',
        templateUrl: $sce.trustAsResourceUrl('http://localhost:3030/templates/purchase_tile.html')
      } // TODO Put in the proper domain name
    }])
  .factory('cs', ['$http', function($http) {
    this.getProduct = function(sku, callback) {
      // TODO Put in the proper domain name
      var url = 'http://localhost:3030/api/v1/products/' + sku;
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
    return this;
  }])
    .controller('purchaseTileController', ['$scope', 'cs', function($scope, cs) {
      $scope.$watch('sku', function(newValue, oldValue) {
        cs.getProduct(newValue, function(product) {
          $scope.price = product.price;
        });
      });
    }]);
})();
