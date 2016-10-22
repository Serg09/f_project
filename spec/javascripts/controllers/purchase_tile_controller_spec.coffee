describe 'purchaseTileController', ->
  beforeEach module('crowdscribed')

  $rootScope = null
  $scope = null
  controller = null
  $httpBackend = null
  beforeEach ->
    inject (_$rootScope_, _$controller_, _$httpBackend_) ->
      $httpBackend = _$httpBackend_
      $rootScope = _$rootScope_
      $scope = $rootScope.$new()
      controller = _$controller_ 'purchaseTileController',
        $scope: $scope


  describe 'sku', ->
    it 'looks up the product and sets the price', ->
      $httpBackend.whenGET('http://localhost:3030/api/v1/products/123456').respond (method, url, data, headers, params)->
        return [200]
       
      $scope.sku = '123456'
      $scope.$digest()
      expect($scope.price).toEqual 19.99
